//
//  VerifyEmailPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol VerifyEmailViewProtocol:AnyObject{
    
}

protocol VerifyEmailPresenterProtocol:AnyObject{
    init(view:VerifyEmailViewProtocol)
    
    func sendVerifyEmail(email:String, password:String, completion: @escaping (Bool, customErrorAuth?)->Void)
    
    func logIn(email:String, password:String, completion: @escaping (Bool, customErrorAuth?)->Void )
    
    func getUserInfoFromApi(completion: @escaping (Bool, customErrorUserData?)->Void)
}
class VerifyEmailPresenter:VerifyEmailPresenterProtocol{
    weak var view:VerifyEmailViewProtocol?
    
    let keychainService = KeychainService()
    let apiAuth = ApiManagerAuth()
    let apiUserData = ApiManagerUserData()
    
    required init(view:VerifyEmailViewProtocol) {
        self.view = view
    }
    
    // MARK: - sendVerifyEmail
    public func sendVerifyEmail(email:String, password:String, completion: @escaping (Bool, customErrorAuth?)->Void){
        self.apiAuth.sendVerifyEmail(email: email, password: password) { isSent, error in
            if error != nil{
                completion(false,error)
            }
            if isSent ?? false{
                completion(true,nil)
            }
        }
    }
    
    // MARK: - logIn
    public func logIn(email:String, password:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        
        let deviceToken = self.keychainService.getDeviceToken() ?? ""
        
        self.apiAuth.logIn(email: email, password: password, deviceToken: deviceToken) { isLogin,logInData, error in
            if error != nil {
                completion(false,error)
                return
            }
            if !isLogin || logInData == nil  {
                completion(false,.unknowmError)
                return
            }
            
            self.keychainService.setAcessToken(token: logInData!.token)
            self.keychainService.setRefreshToken(token: logInData!.refreshToken)
            self.keychainService.setLocalId(id: logInData!.localId)
                                    
            completion(true,nil)
            
        }
    }
    
    public func getUserInfoFromApi(completion: @escaping (Bool, customErrorUserData?)->Void){
        
        self.apiUserData.getUserInfo(token: keychainService.getAcessToken() ?? "") { isInfo, response, error in
            
            
            if error != nil{
                completion(false, error)
                self.keychainService.removeAllData()
                
                return
            }
            
            self.keychainService.setEmail(email: response!.email)
            self.keychainService.setFirstName(firstName: response!.first_name)
            self.keychainService.setSecondName(secondName: response!.last_name)
            self.keychainService.setPhone(phone: response!.phone)
            self.keychainService.setCompanyLocalId(companyLocalId: response!.company_id)
            self.keychainService.setCompanyName(companyName: response!.company_name)
            self.keychainService.setBirthday(birthday: response!.birthday_date)
            
            completion(true, nil)
            
        }
    }
}
