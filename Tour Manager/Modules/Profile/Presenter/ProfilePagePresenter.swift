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
    
    func deletePhotoSuccess()
    func deletePhotoError()
    func uploadSuccess(image:UIImage)
    func uploadError()
    
    func updateInfoError()
    func updateInfoSuccess()
    
    func updateCompanyInfoError()
    func updateCompanyInfoSuccess()
    
    func logoutSuccess()
    func logoutError()
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
    
    func uploadProfilePhoto(image:UIImage)
    func deleteProfilePhoto()
    
    func updatePersonalData(updateField: UserDataFields,value:String) 
    
    func updateCompanyInfo(companyName:String)
    
    func logOut()
    
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
    
    public func getProfilePhoto(){
        downloadProfilePhoto()
        
        if let imageData = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.image{
            view?.setProfilePhoto(image: UIImage(data: imageData)!)
        }else{
            view?.setProfilePhoto(image: UIImage(resource: .noProfilePhoto))
        }
        
    }
    
    public func getProfilePhotoFromRealm() -> UIImage{
        if let imageData = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.image{
            UIImage(data: imageData)!
        }else{
            UIImage(resource: .noProfilePhoto)
        }
    }
    
    public func getFirstName() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.firstName ?? ""
    }
    public func getSecondName() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.secondName ?? ""
    }
    
    public func getFullName() ->String{
        let user = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")
        return (user?.firstName ?? "") + " " + (user?.secondName ?? "")
    }
    
    public func getBirthday() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.birthday?.birthdayToString() ?? ""
    }
    
    public func getPhone() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.phone ?? ""
    }
    
    public func getEmail() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.email ?? ""
    }
    
    
    public func deleteCurrentUser(completion: @escaping (Bool, customErrorUserData?)->Void){
        self.apiUserData.deleteCurrentUser(token: keychain.getAcessToken() ?? "") { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func logOut(){
        Task{
            do{
                if try await self.apiAuth.logOut(){
                    DispatchQueue.main.async {
                        self.view?.logoutSuccess()
                    }
                    
                }
            }catch{
                DispatchQueue.main.async {
                    self.view?.logoutError()
                }
            }
        }
        
    }
    
    public func DeleteCompany(completion: @escaping (Bool, customErrorCompany?) ->Void){
        self.apiCompany.DeleteCompany(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "") { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    
    public func uploadProfilePhoto(image:UIImage){
        Task{
            do{
                if try await self.apiUserData.uploadProfilePhoto(image:image){
                    DispatchQueue.main.async {
                        self.usersRealmService.updateImage(id: self.keychain.getLocalId() ?? "", image: image.pngData()!)
                        self.view?.uploadSuccess(image: image)
                    }
                }
                
            } catch{
                DispatchQueue.main.async {
                    self.view?.uploadError()
                }
                
            }
            
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
    
    public func deleteProfilePhoto(){
        Task{
            do{
                if try await self.apiUserData.deleteProfilePhoto(){
                    DispatchQueue.main.async {
                        self.usersRealmService.deleteImage(id: self.keychain.getAcessToken() ?? "")
                        self.view?.deletePhotoSuccess()
                    }
                }
            }catch{
                
            }
        }
    }
    
    public func updatePersonalData(updateField: UserDataFields,value:String) {
        Task{
            do{
                if try await self.apiUserData.updateUserInfo(updateField: updateField, value: value){
                    DispatchQueue.main.async {
                        if updateField == .birthdayDate{
                            self.usersRealmService.updateBirhday(localId: self.keychain.getLocalId() ?? "", date: Date.birthdayFromString(dateString: value))
                        }else{
                            self.usersRealmService.updateField(localId: self.keychain.getLocalId() ?? "", updateField: updateField, value: value)
                        }
                        
                        self.view?.updateInfoSuccess()
                    }
                    
                }
                
            } catch{
                DispatchQueue.main.async {
                    self.view?.updateInfoError()
                }
                
            }
        }
    }
    
    public func updateCompanyInfo(companyName:String){
        Task{
            do{
                if try await self.apiCompany.updateCompanyInfo(companyName:companyName){
                    DispatchQueue.main.async {
                        self.keychain.setCompanyName(companyName: companyName)
                        self.view?.updateCompanyInfoSuccess()
                    }
                    
                }
            } catch{
                DispatchQueue.main.async {
                    self.view?.updateCompanyInfoError()
                }
                
            }
        }
    }
    
}
