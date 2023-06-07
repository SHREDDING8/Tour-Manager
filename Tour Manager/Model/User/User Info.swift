//
//  User Info.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.06.2023.
//

import Foundation
import UIKit

extension User{
    // MARK: - getUserInfoFromApi
    
    public func getUserInfoFromApi(completion: @escaping (Bool, customErrorUserData?)->Void){
        self.apiUserData.getUserInfo(token: self.token ?? "" ) { isInfo, response, error in
            
            
            if error != nil{
                completion(false, error)
                UserDefaults.standard.set(nil, forKey:  "authToken")
                UserDefaults.standard.set(nil, forKey: "localId")
                return
            }
            
            if response == nil || !isInfo{
                completion(false, .unknowmError)
                return
            }
            
            self.setEmail(email: response!.email)
            self.setFirstName(firstName: response!.first_name)
            self.setSecondName(secondName: response!.last_name)
            self.setPhone(phone: response!.phone)
            self.setBirthday(birthday: Date.birthdayFromString(dateString: response!.birthday_date))
            
            self.company.setLocalIDCompany(localIdCompany: response!.company_id)
            self.company.setNameCompany(nameCompany: response!.company_name)
            
            
            self.company.setIsPrivate(isPrivate: response!.private_company)
            
            
            completion(true, nil)
            
        }
    }
    
    // MARK: - setUserInfoApi
    
    public func setUserInfoApi(completion: @escaping (Bool, customErrorUserData?)->Void){
        let data = UserDataServerStruct(token: self.token ?? "", email: self.email! , first_name: self.firstName!, last_name: self.secondName!, birthday_date: self.getBirthday(), phone: self.phone!)
        
        self.apiUserData.setUserInfo(data: data) { isSetted, error in
            completion(isSetted,error)
        }
    }
    
    
    // MARK: - updatePersonalData
    
    public func updatePersonalData(updateField: UserDataFields ,value:String, completion:  @escaping (Bool, customErrorUserData? )->Void ){
        self.apiUserData.updateUserInfo(token: self.getToken() , updateField: updateField , value: value) { isSetted, error in
            if error != nil{
                completion(false, error)
            } else{
                switch updateField {
                case .firstName:
                    self.setFirstName(firstName: value)
                case .secondName:
                    self.setSecondName(secondName: value)
                case .birthdayDate:
                    self.setBirthday(birthday: Date.birthdayFromString(dateString: value))
                case .phone:
                    self.setPhone(phone: value)
                }
                completion(true, nil)
            }
        }
    }
    
    // MARK: - deleteCurrentUser
    public func deleteCurrentUser(completion: @escaping (Bool, customErrorUserData?)->Void){
        self.apiUserData.deleteCurrentUser(token: self.getToken()) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    // MARK: - UploadPhoto
    public func uploadProfilePhoto(image:UIImage, completion: @escaping (Bool,customErrorUserData?)->Void){
        
        self.apiUserData.uploadProfilePhoto(token: self.getToken(), image: image) { isUploaded, error in
            completion(isUploaded,error)
        }
    }
    
    public func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void){
        
        self.apiUserData.downloadProfilePhoto(token: self.getToken(), localId: localId) { isDownloaded, data, error in
            
            completion(data,error)
        }
    }
    
    public func deleteProfilePhoto(completion: @escaping (Bool,customErrorUserData?)->Void){
        
        self.apiUserData.deleteProfilePhoto(token: self.getToken()) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
}
