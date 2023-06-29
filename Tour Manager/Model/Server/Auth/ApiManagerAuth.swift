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
    
    case emailExist
    
    case weakPassword
    
    case userNotFound
    
    case unknowmError
    
    case tokenExpired
}


public class ApiManagerAuth{
    private static let domain = GeneralData.domain
    private static let prefix = domain + "auth"
    
    private let routeRefreshToken = prefix + "/refresh_user_token"
    private let routeLogIn = prefix + "/login"
    private let routeSignIn = prefix + "/signup"
    
    private let routeIsEmailBusy = prefix + "/check_user_email"
   
    private let routeResetPassword = prefix + "/reset_password"
    private let routeSendVerifyEmail = prefix + "/send_verify_email"
    private let routeUpdatePassword = prefix + "/update_user_password"
    
    
    
    
    public func refreshToken(refreshToken:String, completion: @escaping (Bool,String?, customErrorAuth?)->Void){
        
        let jsonData = ["refresh_token":refreshToken]
        
        let url = URL(string: routeRefreshToken)!
        
        AF.request(url,method: .post, parameters: jsonData,encoder: .json).response{
            response in
            
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data!)
                completion(false,nil, error)
            }else if response.response?.statusCode == 200{
                
                let newToken = try! JSONDecoder().decode(ResponseRefreshToken.self, from: response.data!)
                completion(false, newToken.token, nil)
                
                
            }else{
                completion(false,nil, nil)
            }
        }
        
    }
    
    // MARK: - logIn
    public func logIn(email:String,password:String, deviceToken:String, completion: @escaping (Bool, ResponseLogInJsonStruct?, customErrorAuth?)->Void ){
        
        let jsonData = sendLogInJsonStruct(email: email, password: password, apnsToken: ApnsToken(vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceToken: deviceToken))
        
        let url = URL(string: routeLogIn)

        AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data!)
                completion(false, nil, error)
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
        
        let jsonData = [
            "email": email,
            "password": password
        ]
        
    
        let url = URL(string: routeSignIn)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 200{
                completion(true,nil)
            }else if response.response?.statusCode == 400 {
                let error = self.checkError(data: response.data!)
                completion(false, error)
            } else{
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
                let error = self.checkError(data: response.data!)
                completion(false, error)
            } else if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                completion(false,.unknowmError)
            }
        }
    }
    
    // MARK: - updatePassword
    public func updatePassword(email:String,oldPassword:String, newPassword:String, completion:  @escaping (Bool,customErrorAuth?)->Void ){
        
        let jsonData = sendUpdatePassword(email: email, old_password: oldPassword, new_password: newPassword)
        
        let url = URL(string: routeUpdatePassword)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data!)
                completion(false, error)
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
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data!)
                completion(nil, error)
                
            }else if response.response?.statusCode == 200{
                let successfulCheckEmail = try! JSONDecoder().decode(ResponseIsUserExistsJsonStruct.self, from: response.data!)
                completion(successfulCheckEmail.userExists,nil)
            }else {
                completion(nil,.unknowmError)
            }
        }
    }
            
    // MARK: - sendVerifyEmail
    public func sendVerifyEmail(email:String, password:String, completion:  @escaping (Bool?,customErrorAuth?)->Void ) {
        
        let jsonData = [
            "email": email,
            "password": password
        ]
        let url = URL(string: routeSendVerifyEmail)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 200{
                completion(true,nil)
            } else {
                completion(nil,.unknowmError)
            }
        }
    }
    
    
    private func checkError(data:Data)->customErrorAuth{
        if let error = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: data){
            print(error.message)
            switch error.message{
            case "Email exists":
                return .emailExist
            case "Email is not verified":
                return .emailIsNotVerifyed
                
            case "Invalid email or password":
                return .invalidEmailOrPassword
                
            case "User was not found":
                return .userNotFound
                
            case "Weak password":
                return .weakPassword
                
            case "TOKEN_EXPIRED":
                return .tokenExpired
                
            default:
                return .unknowmError
            }
        }
        return .unknowmError
    }
    
}
