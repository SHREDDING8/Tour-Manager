//
//  ProfilePagePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.08.2023.
//

import Foundation
import UIKit

protocol ProfileViewProtocol:AnyObject{
    
}

protocol ProfilePagePresenterProtocol:AnyObject{
    init(view:ProfileViewProtocol)
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    func getCompanyName() -> String
    
    func getFirstName() ->String
    func getSecondName() ->String
    
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
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.birthday.birthdayToString() ?? ""
    }
    
    func getPhone() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.phone ?? ""
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
    
    public func downloadProfilePhoto(completion: @escaping (Data?,customErrorUserData?)->Void){
        
        self.apiUserData.downloadProfilePhoto(token: keychain.getAcessToken() ?? "", localId: keychain.getLocalId() ?? "") { isDownloaded, data, error in
            
            completion(data,error)
        }
    }
    
    public func deleteProfilePhoto(completion: @escaping (Bool,customErrorUserData?)->Void){
        
        self.apiUserData.deleteProfilePhoto(token: keychain.getAcessToken() ?? "" ) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func updatePersonalData(updateField: UserDataFields,value:String, completion:  @escaping (Bool, customErrorUserData? )->Void ){
        self.apiUserData.updateUserInfo(token: keychain.getAcessToken() ?? "" , updateField: updateField , value: value) { isSetted, error in
            if error != nil{
                completion(false, error)
            } else{
                if updateField == .birthdayDate{
                    self.usersRealmService.updateBirhday(localId: self.keychain.getLocalId() ?? "", date: Date.birthdayFromString(dateString: value))
                }else{
                    self.usersRealmService.updateField(localId: self.keychain.getLocalId() ?? "", updateField: updateField, value: value)
                }
                completion(true, nil)
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
