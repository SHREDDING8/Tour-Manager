//
//  ApiManagerAuth.swift
//  Tour Manager
//
//  Created by SHREDDING on 30.04.2023.
//

import Foundation
import Alamofire

public enum customErrorAuth{
    case invalidEmailOrPassword
    
    case emailIsNotVerifyed
    
    case userNotFound
    
    case unknowmError
}


public class ApiManagerAuth{
    private static let domain = GeneralData.domain
    private static let prefix = domain + "auth"
    
    private let routeLogIn = prefix + "/login"
    private let routeSignIn = prefix + "/signup"
    
    private let routeIsEmailBusy = prefix + "/check_user_email"
   
    private let routeResetPassword = prefix + "/reset_password"
    private let routeSendVerifyEmail = prefix + "/send_verify_email"
    private let routeUpdatePassword = prefix + "/update_user_password"
    
    // MARK: - logIn
    public func logIn(email:String,password:String, completion: @escaping (Bool, ResponseLogInJsonStruct?, customErrorAuth?)->Void ){
        
        let jsonData = sendLogInJsonStruct(email: email, password: password)
        
        let url = URL(string: routeLogIn)
        
        AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let errorData = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if errorData?.message == "Email is not verified"{
                    completion(false,nil,.emailIsNotVerifyed)
                    
                } else if errorData?.message == "Invalid email or password"{
                    completion(false,nil, .invalidEmailOrPassword)
                    
                }else if errorData?.message == "There was an error logging in"{
                    completion(false,nil, .unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                if let logInData = try? JSONDecoder().decode(ResponseLogInJsonStruct.self, from: response.data!){
                    completion(true, logInData, nil)
                }
            } else {
                completion(false, nil, .unknowmError)
            }
        }
        
    }
    
    // MARK: - signIn
    public func signIn(email:String,password:String, completion: @escaping (Bool,customErrorAuth?)->Void ){
        
        let jsonData = sendLogInJsonStruct(email: email, password: password)
    
        let url = URL(string: routeSignIn)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 200{
                completion(true,nil)
            }else{
                completion(false,.unknowmError)
            }
        }
    }
    
    // MARK: - Reset Password
    public func resetPassword(email:String,completion:  @escaping (Bool,customErrorAuth?)->Void){
        let jsonData = sendResetPassword(email: email)
        
        let url = URL(string: routeResetPassword)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                if let logInData = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!){
                    if logInData.message == "User was not found"{
                        completion(false,.userNotFound)
                    } else{
                        completion(false,.unknowmError)
                    }
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                completion(false,.unknowmError)
            }
        }
    }
    
    public func updatePassword(email:String,oldPassword:String, newPassword:String, completion:  @escaping (Bool,customErrorAuth?)->Void ){
        
        let jsonData = sendUpdatePassword(email: email, old_password: oldPassword, new_password: newPassword)
        
        let url = URL(string: routeUpdatePassword)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                if let logInData = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!){
                    if logInData.message == "Email is not verified"{
                        completion(false,.emailIsNotVerifyed)
                        
                    }else if logInData.message == "Invalid email or password" {
                        completion(false,.invalidEmailOrPassword)
                    }else{
                        completion(false,.unknowmError)
                    }
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                completion(false,.unknowmError)
            }
        }

    }
    
    // MARK: - isUserExists
    public func isUserExists(email:String, completion:  @escaping (Bool?,customErrorAuth?)->Void ){
        
        let jsonData = sendResetPassword(email: email)
        
        let url = URL(string: routeIsEmailBusy)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in

            if response.response?.statusCode == 200{
                if let successfulCheckEmail = try? JSONDecoder().decode(ResponseIsUserExistsJsonStruct.self, from: response.data!){
                    completion(successfulCheckEmail.userExists,nil)
                } else{
                    completion(nil,.unknowmError)
                }
            }else {
                completion(nil,.unknowmError)
            }
        }
    }
    
    // MARK: - sendVerifyEmail
    public func sendVerifyEmail(email:String, password:String, completion:  @escaping (Bool?,customErrorAuth?)->Void ) {
        let jsonData = sendLogInJsonStruct(email: email, password: password)
        
        let url = URL(string: routeSendVerifyEmail)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                completion(nil,.unknowmError)
            }
        }
    }
    
}
