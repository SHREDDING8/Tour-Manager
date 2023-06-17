//
//  Auth.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.06.2023.
//

import Foundation

// MARK: - Auth

extension User{
    
   
    // MARK: - setDataAuth
    public func setDataAuth(token:String,localId:String){
        self.token = token
        self.localId = localId
    }
    
    // MARK: - logIn
    public func logIn(password:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.logIn(email: self.email ?? "", password: password) { isLogin,logInData, error in
            if error != nil {
                completion(false,error)
                return
            }
            if !isLogin || logInData == nil  {
                completion(false,.unknowmError)
                return
            }
            
            self.setDataAuth(token: logInData!.token, localId: logInData!.localId)
            
            UserDefaults.standard.set(self.getToken(), forKey:  "authToken")
            UserDefaults.standard.set(self.getLocalID(), forKey: "localId")
            
            completion(true,nil)
            
        }
    }
    
    // MARK: - signIn
    public func signIn(password:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        
        self.apiAuth.signIn(email: self.email ?? "", password: password) { isSignIn, error in
            // check errors from api
            if error != nil{
                completion(false, error)
            }
            if isSignIn{
                completion(true,nil)
            }
        }
    }
    
    // MARK: - resetPassword
    public func resetPassword(completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.resetPassword(email: self.email ?? "") { isSendEmail, error in
            if error != nil{
                completion(false,error)
                return
            }
            completion(true,nil)
        }
    }
    
    // MARK: - updatePassword
    public func updatePassword(oldPassword:String, newPassword:String,completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.updatePassword(email: self.getEmail(), oldPassword: oldPassword, newPassword: newPassword) { isUpdated, error in
            if error != nil{
                completion(false,error)
                return
            }
            completion(true,nil)
        }
    }
    
    // MARK: - sendVerifyEmail
    public func sendVerifyEmail(password:String, completion: @escaping (Bool, customErrorAuth?)->Void){
        self.apiAuth.sendVerifyEmail(email: self.email ?? "", password: password) { isSent, error in
            if error != nil{
                completion(false,error)
            }
            if isSent ?? false{
                completion(true,nil)
            }
        }
    }
    
    // MARK: - isUserExists
    public func isUserExists(completion: @escaping (Bool, customErrorAuth?)->Void){
        self.apiAuth.isUserExists(email: self.email ?? "") { isUserExists, error in
            
            if error != nil{
                completion(false,error)
            }
            
            completion(isUserExists ?? false, nil)
        }
    }
    
}