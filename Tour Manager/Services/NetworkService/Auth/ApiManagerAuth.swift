//
//  ApiManagerAuth.swift
//  Tour Manager
//
//  Created by SHREDDING on 30.04.2023.
//

import Foundation
import Alamofire

public enum customErrorAuth:Error{
    case invalidEmailOrPassword
    
    case emailIsNotVerifyed
    
    case emailExist
    
    case weakPassword
    
    case userNotFound
    
    case unknowmError
    
    case tokenExpired
    
    case notConnected
}

protocol ApiManagerAuthProtocol{
    func logIn(email:String,password:String, deviceToken:String) async throws -> ResponseLogInJsonStruct
    
    func signUp(email:String,password:String) async throws -> Bool
    
    func resetPassword(email:String) async -> Bool
    
    func sendVerifyEmail(email:String, password:String) async -> Bool
    
    static func refreshToken() async throws -> Bool
}


public class ApiManagerAuth: ApiManagerAuthProtocol{
    
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
        
        self.routeLogIn = prefix + "login"
        self.routeLogOut = prefix + "logout"
        self.routeSignIn = prefix + "signup"
        
        self.routeIsEmailBusy = prefix + "check_user_email"
       
        self.routeResetPassword = prefix + "reset_password"
        self.routeSendVerifyEmail = prefix + "send_verify_email"
        self.routeUpdatePassword = prefix + "update_user_password"
    }
    
    
    // MARK: - logIn
    func logIn(email:String,password:String,deviceToken:String) async throws -> ResponseLogInJsonStruct{
        
        let jsonData = await SendLogInJsonStruct(email: email, password: password, apnsToken: ApnsToken(vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceToken: deviceToken, deviceName: UIDevice.current.name))
        
        let url = URL(string: routeLogIn)
        
        let result:ResponseLogInJsonStruct = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data!)
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        if let logInData = try? JSONDecoder().decode(ResponseLogInJsonStruct.self, from: response.data!){
                            
                            continuation.resume(returning: logInData)
                        }
                    } else {
                        continuation.resume(throwing: customErrorAuth.unknowmError)
                    }
                    
                case .failure(_):
                    continuation.resume(throwing: customErrorAuth.unknowmError)
                }
                
            }
        }
        
        return result
        
    }
    
    static func refreshToken() async throws -> Bool{
        let keychainService = KeychainService()
        let generalData = GeneralData()
        
        if keychainService.isAcessTokenAvailable(){
            return true
        }
        
        let refreshToken = keychainService.getRefreshToken() ?? ""
        
        
        let jsonData = ["refresh_token": refreshToken]
        
        let url = URL(string: generalData.domain + "auth/refresh_user_token")!
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url,method: .post, parameters: jsonData,encoder: .json).response{
                response in
                
                if response.response?.statusCode == 200{
                    
                    let newToken = try! JSONDecoder().decode(ResponseRefreshToken.self, from: response.data!)
                    keychainService.setAcessToken(token: newToken.token)
                    continuation.resume(returning: true)                    
                }else{
                    continuation.resume(returning: false)
                }
            }
        }
        
        return result
        
    }
    
    public func logIn(email:String,password:String, deviceToken:String, completion: @escaping (Bool, ResponseLogInJsonStruct?, customErrorAuth?)->Void ){
        
        let jsonData = SendLogInJsonStruct(email: email, password: password, apnsToken: ApnsToken(vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceToken: deviceToken, deviceName: UIDevice.current.name))
        
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
//                        self.userDefaults.setLastRefreshDate(date: Date.now)
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
    
    
    // MARK: - signUp
    func signUp(email:String,password:String) async throws -> Bool{
        
        let jsonData = [
            "email": email,
            "password": password
        ]
        
        let url = URL(string: routeSignIn)
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    }else if response.response?.statusCode == 400 {
                        let error = self.checkError(data: response.data!)
                        continuation.resume(throwing: error)
                    } else{
                        continuation.resume(throwing: customErrorAuth.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorAuth.unknowmError)
                }
            }
            
        }
        
        return result
        
    }
        
    // MARK: - Reset Password
    func resetPassword(email:String) async -> Bool{
        let jsonData = sendResetPassword(email: email)
        let url = URL(string: routeResetPassword)
        
        let result:Bool = await withCheckedContinuation { continuation in
            
            AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
                continuation.resume(returning: response.response?.statusCode == 200 ? true : false)
            }
        }
        
        return result
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
            
    // MARK: - sendVerifyEmail
    func sendVerifyEmail(email:String, password:String) async -> Bool{
        
        let jsonData = [
            "email": email,
            "password": password
        ]
        
        let url = URL(string: routeSendVerifyEmail)
        
        let result:Bool = await withCheckedContinuation { continuation in
            
            AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
                
                if response.response?.statusCode == 200{
                    continuation.resume(returning: true)
                }else{
                    continuation.resume(returning: false)
                }
            }
        }
        
        return result
        
    }
    
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
//            print(error.message)
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
