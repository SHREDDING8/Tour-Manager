//
//  ProfilePagePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.08.2023.
//

import Foundation
import UIKit

protocol ProfileViewProtocol:AnyObject{
    func setProfilePhoto(image:UIImage)
}

protocol ProfilePagePresenterProtocol:AnyObject{
    init(view:ProfileViewProtocol)
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    func getCompanyName() -> String
    func getCompanyId() -> String
    
    func getProfilePhoto()
    func getProfilePhotoFromRealm() -> UIImage
    func getFirstName() ->String
    func getSecondName() ->String
    func getFullName() ->String
    func getBirthday() -> String
    func getPhone() -> String
    func getEmail() -> String
    
//    func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void)
}
class ProfilePagePresenter:ProfilePagePresenterProtocol{
    weak var view:ProfileViewProtocol?
    
    let keychain = KeychainService()
    let usersRealmService = UsersRealmService()
    
    let apiUserData = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    let apiAuth = ApiManagerAuth()
    
    required init(view:ProfileViewProtocol) {
        self.view = view
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    public func getCompanyName() -> String{
        return keychain.getCompanyName() ?? ""
    }
    
    public func getCompanyId() -> String{
        return keychain.getCompanyLocalId() ?? ""
    }
    
    func getProfilePhoto(){
        downloadProfilePhoto()
        
        if let imageData = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.image{
            view?.setProfilePhoto(image: UIImage(data: imageData)!)
        }else{
            view?.setProfilePhoto(image: UIImage(resource: .noProfilePhoto))
        }
        
    }
    
    func getProfilePhotoFromRealm() -> UIImage{
        if let imageData = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.image{
            UIImage(data: imageData)!
        }else{
            UIImage(resource: .noProfilePhoto)
        }
    }
    
    func getFirstName() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.firstName ?? ""
    }
    func getSecondName() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.secondName ?? ""
    }
    
    func getFullName() ->String{
        let user = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")
        return (user?.firstName ?? "") + " " + (user?.secondName ?? "")
    }
    
    func getBirthday() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.birthday?.birthdayToString() ?? ""
    }
    
    func getPhone() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.phone ?? ""
    }
    
    func getEmail() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.email ?? ""
    }
    
    
    public func deleteCurrentUser(completion: @escaping (Bool, customErrorUserData?)->Void){
        self.apiUserData.deleteCurrentUser(token: keychain.getAcessToken() ?? "") { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func logOut(completion: @escaping (Bool, customErrorAuth?)->Void){
                
        self.apiAuth.logOut(token: keychain.getAcessToken() ?? "" ) { isLogout, error in
                completion(isLogout,error)
        }
        
    }
    
    public func DeleteCompany(completion: @escaping (Bool, customErrorCompany?) ->Void){
        self.apiCompany.DeleteCompany(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "") { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    
    public func uploadProfilePhoto(image:UIImage, completion: @escaping (Bool,customErrorUserData?)->Void){
        
        self.apiUserData.uploadProfilePhoto(token: keychain.getAcessToken() ?? "", image: image) { isUploaded, error in
            completion(isUploaded,error)
        }
    }
    
    private func downloadProfilePhoto(){
        Task{
            do{
                let imageData = try await self.apiUserData.downloadProfilePhoto(localId: keychain.getLocalId() ?? "")
                
                DispatchQueue.main.async {
                    self.usersRealmService.updateImage(id: self.keychain.getLocalId() ?? "", image: imageData)
                    self.view?.setProfilePhoto(image: UIImage(data: imageData)!)
                }

            }catch{
                
            }
        }
    }
    
    public func deleteProfilePhoto(completion: @escaping (Bool,customErrorUserData?)->Void){
        
        self.apiUserData.deleteProfilePhoto(token: keychain.getAcessToken() ?? "" ) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func updatePersonalData(updateField: UserDataFields,value:String) {
        Task{
            do{
                if try await self.apiUserData.updateUserInfo(updateField: updateField, value: value){
                    if updateField == .birthdayDate{
                        self.usersRealmService.updateBirhday(localId: self.keychain.getLocalId() ?? "", date: Date.birthdayFromString(dateString: value))
                    }else{
                        self.usersRealmService.updateField(localId: self.keychain.getLocalId() ?? "", updateField: updateField, value: value)
                    }
                }
                
            } catch{
                
            }
        }
        
    }
    
    public func updateCompanyInfo(companyName:String, completion: @escaping (Bool, customErrorCompany?) ->Void){
        self.apiCompany.updateCompanyInfo(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", companyName: companyName) { isUpdated, error in
            if error != nil{
                completion(false,error)
            }
            
            if isUpdated{
                self.keychain.setCompanyName(companyName: companyName)
                completion(true, nil)
            }
        }
    }
    
}
