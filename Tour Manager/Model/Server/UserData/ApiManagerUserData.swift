//
//  ApiManagerUserData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire


public enum customErrorUserData{
    case tokenExpired
    case invalidToken
    
    case dataNotFound
    
    case unknowmError
    
}

public enum UserDataFields:String{
    case firstName = "first_name"
    case secondName = "last_name"
    case birthdayDate = "birthday_date"
    case phone = "phone"
}




public class ApiManagerUserData{
    private static let domain = GeneralData.domain
    private static let prefix = GeneralData.domain + "users"
    
    private let routeGetUserInfo = prefix + "/get_user_info"
    private let routeSetUserInfo = prefix + "/update_user_info"
    
    private let routeDeleteCurrentUser = prefix + "/delete_current_user_account"
    
//    private let routeUpdateEmail = prefix + "/update_user_email"
    
    
    // MARK: - getUserInfo
    public func getUserInfo(token:String, completion: @escaping (Bool,ResponseGetUserInfoJsonStruct?,customErrorUserData?)->Void ){
        let url = URL(string: routeGetUserInfo)
        
        
        let jsonData = SendGetUserInfoJsonStruct(token: token)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "User data not found"{
                    completion(false, nil, .dataNotFound)
                } else if error.message == "Token expired"{
                    completion(false, nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, nil, .invalidToken)
                } else {
                    completion(false, nil, .unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                if let responseData = try? JSONDecoder().decode(ResponseGetUserInfoJsonStruct.self, from: response.data!){
                    completion(true, responseData, nil)
                    
                }else{
                    completion(false, nil, .unknowmError)
                }
            } else {
                completion(false, nil, .unknowmError)
            }
        }
    }
    
    
    // MARK: - setUserInfo
    public func setUserInfo(data:UserDataServerStruct ,completion: @escaping (Bool,customErrorUserData?)->Void ){
        let url = URL(string: routeSetUserInfo)
        
        let jsonData = data
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired" || error.message == "Invalid Firebase ID token" {
                    completion(false, .invalidToken)
                } else {
                    completion(false, .unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                
                completion(false, .unknowmError)
            }
        }
    }
    
    // MARK: - updateUserInfo
    public func updateUserInfo(token:String, updateField: UserDataFields, value:String, completion: @escaping (Bool,customErrorUserData?)->Void ){
        
        let url = URL(string: routeSetUserInfo)
        let jsonData = [
            "token": token,
            updateField.rawValue : value
        ]
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired" || error.message == "Invalid Firebase ID token" {
                    completion(false, .invalidToken)
                } else {
                    completion(false, .unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                completion(false, .unknowmError)
            }
        }
    }
    
    
    public func deleteCurrentUser(token:String, completion: @escaping (Bool,customErrorUserData?)->Void  ){
        
        let url = URL(string: routeDeleteCurrentUser)
        let jsonData = [
            "token": token,
        ]
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired" || error.message == "Invalid Firebase ID token" {
                    completion(false, .invalidToken)
                } else {
                    completion(false, .unknowmError)
                }
            } else if response.response?.statusCode == 200{
                completion(true,nil)
            }else{
                completion(false, .unknowmError)
            }
            
        }
    }
//    // MARK: - updateEmail
//    
//    public func updateEmail(token:String, email:String, completion: @escaping (Bool,customErrorUserData?)->Void ){
//        let url = URL(string: routeSetUserInfo)
//        let jsonData = [
//            "token": token,
//            "email": email
//        ]
//        
//        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
//            
//            if response.response?.statusCode == 400{
//                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
//                
//                if error.message == "Token expired" || error.message == "Invalid Firebase ID token" {
//                    completion(false, .invalidToken)
//                } else {
//                    completion(false, .unknowmError)
//                }
//                return
//            } else if response.response?.statusCode == 200{
//                completion(true,nil)
//            } else {
//                completion(false, .unknowmError)
//            }
//            
//        }
//    }
    
}
