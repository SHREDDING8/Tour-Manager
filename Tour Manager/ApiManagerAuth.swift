//
//  ApiManagerAuth.swift
//  Tour Manager
//
//  Created by SHREDDING on 30.04.2023.
//

import Foundation
import Alamofire



public class ApiManagerAuth{
    private static let domain = GeneralData.domain
    private static let routeSignIn = "auth/signup"
    private static let routeIsEmailBusy = "auth/check_user_email"
    private static let routeLogIn = "auth/login"
    
    private static let routeResetPassword = "auth/reset_password"
    private static let routeIsverified = "auth/is_verified"
    
    
    
    public enum customError{
        case unknowmError
        case requestTimedOut
        
        case emailIsNotVerifyed
        
        case invalidEmailOrPassword
        
        case userNotFound
    }
    
    
    public static func logIn(email:String,password:String, completion: @escaping (Bool,customError?)->Void ){
        
        let jsonData:[String: String] = [
            "email": email,
            "password": password
        ]
        
        let url = URL(string: domain+routeLogIn)
        
        AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let errorData = try? JSONDecoder().decode(LogInErrorJsonStruct.self, from: response.data!)
                if errorData?.message == "Email is not verified"{
                    completion(false,.emailIsNotVerifyed)
                    return
                }
                
                if errorData?.message == "Invalid email or password"{
                    completion(false,.invalidEmailOrPassword)
                    return
                }
                
                if errorData?.message == "There was an error logging in"{
                    completion(false,.unknowmError)
                    return
                }
            }
            
            if response.response?.statusCode == 200{
                if let logInData = try? JSONDecoder().decode(LogInJsonStruct.self, from: response.data!){
                    AppDelegate.user.setDataAuth(token: logInData.token, localId: logInData.localId)
                    AppDelegate.user.setEmail(email: email)
                    completion(true,nil)
                }
                
                
                
                
                
            }
        }
        
    }
    
    public static func signIn(email:String,password:String, completion: @escaping (Bool,customError?)->Void ){
        
        let jsonData:[String: String] = [
            "email": email,
            "password": password
        ]
    
        let url = URL(string: domain+routeSignIn)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.error != nil{
                completion(false,.unknowmError)
                return
            }
            
            let unprocessableEntity = try? JSONDecoder().decode(UnprocessableEntity.self, from: response.data!)
            
            if unprocessableEntity != nil {
                completion(false,.unknowmError)
            }
            
            if response.response?.statusCode == 200{
                
                completion(true,nil)
            }else{
                completion(false,.unknowmError)
            }
        }
 
    }
    
    // MARK: - Reset Password
    public static func resetPassword(email:String,completion:  @escaping (Bool,customError?)->Void){
        let jsonData:[String: String] = ["email": email]
        
        let url = URL(string: domain+routeResetPassword)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                if let logInData = try? JSONDecoder().decode(LogInErrorJsonStruct.self, from: response.data!){
                    if logInData.message == "User was not found"{
                        completion(false,.userNotFound)
                    } else if logInData.message == "Unknown error"{
                        completion(false,.unknowmError)
                    }
                }
                return
            }
            completion(true,nil)
            
        }
    }
    
    public static func isUserExists(email:String, completion:  @escaping (Bool?,customError?)->Void ){
        
        let jsonData:[String: String] = ["email": email]
        
        let url = URL(string: domain+routeIsEmailBusy)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            
            if response.error?.localizedDescription.localizedStandardContains("The request timed out") == true{
                completion(nil, .requestTimedOut)
                
            }
            if response.error != nil{
                completion(nil,.unknowmError)
                return
            }
            if response.response?.statusCode == 400{
                completion(nil, .unknowmError)
                return
            }
            
            let unprocessableEntity = try? JSONDecoder().decode(UnprocessableEntity.self, from: response.data!)
            
            if unprocessableEntity != nil{
                completion(nil,.unknowmError)
                return
            }
            
            let successfulCheckEmail = try? JSONDecoder().decode(SuccessfulCheckEmail.self, from: response.data!)
            
            if successfulCheckEmail == nil{
                completion(nil,.unknowmError)
                return
            }
            
            if successfulCheckEmail?.userExists == true{
                completion(true,nil)
            }else{
                completion(false, nil)
            }
        }
    }
    
    
    
//    public static func isEmailVerified(email:String,password:String, completion:  @escaping (Bool?,customError?)->Void ){
//
//        let jsonData:[String: String] = ["email": email, "password":password]
//
//        let url = URL(string: domain+routeIsverified)
//
//        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
//            if response.error != nil{
//                completion(nil,.unknowmError)
//                return
//            }
//            if response.response?.statusCode == 400{
//                completion(nil, .unknowmError)
//                return
//            }
//
//            let isVerified = try? JSONDecoder().decode(isVerifyJsonStruct.self, from: response.data!)
//
//            if isVerified == nil{
//                completion(nil,.unknowmError)
//                return
//            }
//
//            if isVerified?.isVerified == true{
//                completion(true,nil)
//            }else{
//                completion(false, nil)
//            }
//
//
//        }
//
//    }
    
    
}
