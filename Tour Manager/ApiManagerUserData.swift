//
//  ApiManagerUserData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire




public class ApiManagerUserData{
    private static let domain = GeneralData.domain
    private static let prefix = GeneralData.domain + "users"
    
    private let routeGetUserInfo = prefix + "/get_user_info"
    private let routeSetUserInfo = prefix + "/update_user_info"
    
    
    private let user = AppDelegate.user
    
    
    
    public enum customErrorUserData{
        case tokenExpired
        case invalidToken
        
        case dataNotFound
        
        case unknowmError
        
    }
    
    
    public func getUserInfo(token:String, completion: @escaping (Bool,customErrorUserData?)->Void ){
        let url = URL(string: routeGetUserInfo)
        
        let jsonData = SendGetUserInfoJsonStruct(token: token)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "User data not found"{
                    completion(false, .dataNotFound)
                } else if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                } else {
                    completion(false, .unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                if let responseData = try? JSONDecoder().decode(ResponseGetUserInfoJsonStruct.self, from: response.data!){
                    self.user.setEmail(email: responseData.email)
                    self.user.setFirstName(firstName: responseData.first_name)
                    self.user.setSecondName(secondName: responseData.last_name)
                    self.user.setPhone(phone: responseData.phone)
                    completion(true, nil)
                }
            } else {
                completion(false, .unknowmError)
            }
        }
    }
    
    
    public func setUserInfo(completion: @escaping (Bool,customErrorUserData?)->Void ){
        let url = URL(string: routeSetUserInfo)
        
        let jsonData = AppDelegate.user.getPersonalData()
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
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
    
}
