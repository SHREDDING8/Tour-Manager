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
    
    case notConnected
}


public class ApiManagerAuth{
    
    let userDefaults = WorkWithUserDefaults()
    
    let generalData = GeneralData()
    
    
    private let domain:String
    private let prefix:String
    
    private let routeLogIn:String
    private let routeLogOut:String
    private let routeSignIn:String
    
    private let routeIsEmailBusy:String
   
    private let routeResetPassword:String
    private let routeSendVerifyEmail:String
    private let routeUpdatePassword:String
    
    init(){
        self.domain = generalData.domain
        self.prefix = domain + "auth/"
        
        self.routeLogIn = prefix + "login/"
        self.routeLogOut = prefix + "logout/"
        self.routeSignIn = prefix + "signup/"
        
        self.routeIsEmailBusy = prefix + "check_user_email/"
       
        self.routeResetPassword = prefix + "reset_password/"
        self.routeSendVerifyEmail = prefix + "send_verify_email/"
        self.routeUpdatePassword = prefix + "update_user_password/"
    }
    
    
    // MARK: - logIn
    public func logIn(email:String,password:String, deviceToken:String, completion: @escaping (Bool, ResponseLogInJsonStruct?, customErrorAuth?)->Void ){
        
        let jsonData = sendLogInJsonStruct(email: email, password: password, apnsToken: ApnsToken(vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceToken: deviceToken, deviceName: UIDevice.current.name))
        
        let url = URL(string: routeLogIn)
        

        AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data!)
                    completion(false, nil, error)
                } else if response.response?.statusCode == 200{
                    if let logInData = try? JSONDecoder().decode(ResponseLogInJsonStruct.self, from: response.data!){
                        completion(true, logInData, nil)
                        self.userDefaults.setLastRefreshDate(date: Date.now)
                    }
                } else {
                    completion(false, nil, .unknowmError)
                }
                
            case .failure(_):
                completion(false, nil, .notConnected)
            }
            
        }
    }
    
    
    public func logOut(token:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        
        self.generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            
            let jsonData = sendLogOut(token: requestToken, apns_vendor_id: UIDevice.current.identifierForVendor?.uuidString ?? "")
            
            let url = URL(string: self.routeLogOut)
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response{
                response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200{
                        completion(true,nil)
                    }else if response.response?.statusCode == 400 {
                        let error = self.checkError(data: response.data!)
                        completion(false, error)
                    }else{
                        completion(false, .unknowmError)
                    }
                case .failure(_):
                    completion(false, .notConnected)
                }
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
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 200{
                    completion(true,nil)
                }else if response.response?.statusCode == 400 {
                    let error = self.checkError(data: response.data!)
                    completion(false, error)
                } else{
                    completion(false,.unknowmError)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
            
        }
    }
    
    // MARK: - Reset Password
    public func resetPassword(email:String,completion:  @escaping (Bool,customErrorAuth?)->Void){
        let jsonData = sendResetPassword(email: email)
        
        let url = URL(string: routeResetPassword)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data!)
                    completion(false, error)
                } else if response.response?.statusCode == 200{
                    completion(true,nil)
                } else {
                    completion(false,.unknowmError)
                }
            case .failure(_):
                completion(false,.notConnected)
            }
        }
    }
    
    // MARK: - updatePassword
    public func updatePassword(email:String,oldPassword:String, newPassword:String, completion:  @escaping (Bool,customErrorAuth?)->Void ){
        
        let jsonData = sendUpdatePassword(email: email, old_password: oldPassword, new_password: newPassword)
        
        let url = URL(string: routeUpdatePassword)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data!)
                    completion(false, error)
                } else if response.response?.statusCode == 200{
                    completion(true,nil)
                } else {
                    completion(false,.unknowmError)
                }
            case .failure(_):
                completion(false,.notConnected)
            }
        }
    }
    
    // MARK: - isUserExists
    public func isUserExists(email:String, completion:  @escaping (Bool?,customErrorAuth?)->Void ){
        
        let jsonData = sendResetPassword(email: email)
        
        let url = URL(string: routeIsEmailBusy)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data!)
                    completion(nil, error)
                    
                }else if response.response?.statusCode == 200{
                    let successfulCheckEmail = try! JSONDecoder().decode(ResponseIsUserExistsJsonStruct.self, from: response.data!)
                    completion(successfulCheckEmail.userExists,nil)
                }else {
                    completion(nil,.unknowmError)
                }
            case .failure(_):
                completion(nil,.notConnected)
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
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 200{
                    completion(true,nil)
                } else {
                    completion(nil,.unknowmError)
                }
            case .failure(_):
                completion(nil,.notConnected)
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
