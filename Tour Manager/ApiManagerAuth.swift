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
    private static let prefix = domain + "auth"
    
    private let routeLogIn = prefix + "/login"
    private let routeSignIn = prefix + "/signup"
    
    private let routeIsEmailBusy = prefix + "/check_user_email"
   
    private let routeResetPassword = prefix + "/reset_password"
    
    let user = AppDelegate.user
    
    
    public enum customError{
        case invalidEmailOrPassword
        
        case emailIsNotVerifyed
        
        case userNotFound
        
        case unknowmError
    }
    
    
    public func logIn(email:String,password:String, completion: @escaping (Bool,customError?)->Void ){
        
        let jsonData = sendLogInJsonStruct(email: email, password: password)
        
        let url = URL(string: routeLogIn)
        
        AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let errorData = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if errorData?.message == "Email is not verified"{
                    completion(false,.emailIsNotVerifyed)
                    
                } else if errorData?.message == "Invalid email or password"{
                    completion(false,.invalidEmailOrPassword)
                    
                }else if errorData?.message == "There was an error logging in"{
                    completion(false,.unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                if let logInData = try? JSONDecoder().decode(ResponseLogInJsonStruct.self, from: response.data!){
                    self.user.setDataAuth(token: logInData.token, localId: logInData.localId)
                    self.user.setEmail(email: email)
                    completion(true,nil)
                }
            } else {
                completion(false,.unknowmError)
            }
        }
        
    }
    
    public func signIn(email:String,password:String, completion: @escaping (Bool,customError?)->Void ){
        
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
    public func resetPassword(email:String,completion:  @escaping (Bool,customError?)->Void){
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
    
    public func isUserExists(email:String, completion:  @escaping (Bool?,customError?)->Void ){
        
        let jsonData = sendResetPassword(email: email)
        
        let url = URL(string: routeIsEmailBusy)
        
        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in

            if response.response?.statusCode != 200{
                completion(nil, .unknowmError)
                return
            }else if response.response?.statusCode == 200{
                if let successfulCheckEmail = try? JSONDecoder().decode(ResponseIsUserExistsJsonStruct.self, from: response.data!){
                    completion(successfulCheckEmail.userExists,nil)
                } else{
                    completion(nil,.unknowmError)
                }
            }
        }
    }
}
