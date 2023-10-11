//
//  LoginViewPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol LoginViewProtocol:AnyObject{
    func setLoginView()
    func setSignUpView()
    func setLoadingView()
    func hideLoadingView()
    
    func resetSuccess(email:String)
    func resetFailure(email:String)
    
    func wrongEmail()
    func wrongEmailOrPassword()
    func passwordsNotValid()
    func passwordsAreNotEqual()
    func unknownError()
    func verifySendError()
    func emailExist()
    
    func goToVerifyVC(email:String, password:String)
    func goToMain()
    func goToAddingPersonalData()
    
    
}

protocol LoginPresenterProtocol:AnyObject{
    init(view:LoginViewProtocol)
    
    func changeSignInLoginTapped()
    
    func setEmail(email:String)
    func setPassword(password:String)
    func setConfirmPassword(password:String)
    
    func isValidEmail(email:String) -> Bool
    
    func removeAllData()
    
    func resetPassword(email:String)
    
    func loginButtonTapped()
        
    func getUserInfoFromApi(completion: @escaping (Bool, customErrorUserData?)->Void)
    
    func sendVerifyEmail(email:String, password:String, completion: @escaping (Bool, customErrorAuth?)->Void)
}

class LoginPresenter:LoginPresenterProtocol{
    weak var view:LoginViewProtocol?
    
    let keychainService = KeychainService()
    let usersRealmService = UsersRealmService()
    let generalRealmService = GeneralRealmService()
    let apiAuth = ApiManagerAuth()
    let authNetworkService:ApiManagerAuthProtocol = ApiManagerAuth()
    let apiUserData = ApiManagerUserData()
    let userDataNetworkService:ApiManagerUserDataProtocol = ApiManagerUserData()
    
    let stringValidation = StringValidation()
    
    var model = loginData()
    
    var isSignIn:Bool = true
    
    required init(view:LoginViewProtocol) {
        self.view = view
    }
    
    func changeSignInLoginTapped(){
        isSignIn = !isSignIn
        model.clearPasswords()
        isSignIn == true ? view?.setLoginView() : view?.setSignUpView()
    }
    
    func setEmail(email:String){
        model.email = email
    }
    
    func setPassword(password:String){
        model.firstPassword = password
    }
    
    func setConfirmPassword(password:String){
        model.secondPassword = password
    }
    
    func isValidEmail(email:String) -> Bool{
        return stringValidation.validateEmail(email)
    }
    
    func removeAllData(){
        keychainService.removeAllData()
        generalRealmService.deleteAll()
    }
    
    func resetPassword(email:String){
        view?.setLoadingView()
        Task{
            let result = await authNetworkService.resetPassword(email: email)
            
            DispatchQueue.main.async {
                self.view?.hideLoadingView()
                
                if result{
                    self.view?.resetSuccess(email:email)
                }else{
                    self.view?.resetFailure(email: email)
                }
            }
        }
    }
    
    func loginButtonTapped(){
        isSignIn == true ? self.login() : self.signUp()
    }
    
    func login(){
        Task{
            do {
                let loginResult = try await self.authNetworkService.logIn(email: model.email, password: model.firstPassword, deviceToken: keychainService.getDeviceToken() ?? "")
                
                keychainService.setLocalId(id: loginResult.localId)
                keychainService.setAcessToken(token: loginResult.token)
                keychainService.setRefreshToken(token: loginResult.refreshToken)
                
                let userDataResult = try await self.userDataNetworkService.getUserInfo()
                
                DispatchQueue.main.async {
                    
                    let me = UserRealm(localId: self.keychainService.getLocalId()!, firstName: userDataResult.first_name, secondName: userDataResult.last_name, email: userDataResult.email, phone: userDataResult.phone, birthday: Date.dateStringToDate(dateString: userDataResult.birthday_date))
                    
                    self.usersRealmService.setUserInfo(user: me)
                    
                    self.keychainService.setCompanyLocalId(companyLocalId: userDataResult.company_id)
                    self.keychainService.setCompanyName(companyName: userDataResult.company_name)
                    
                    self.view?.goToMain()
                }
                
            } catch customErrorAuth.emailIsNotVerifyed{
                
                if await authNetworkService.sendVerifyEmail(email: model.email, password: model.firstPassword){
                    self.view?.goToVerifyVC(email: model.email, password: model.firstPassword)
                }else{
                    view?.verifySendError()
                }
                
            } catch customErrorAuth.invalidEmailOrPassword{
                DispatchQueue.main.async {
                    self.view?.wrongEmailOrPassword()
                }
                
            } catch customErrorAuth.unknowmError{
                DispatchQueue.main.async {
                    self.view?.unknownError()
                }
                
            } catch customErrorUserData.dataNotFound{
                view?.goToAddingPersonalData()
            }
            
        }
    }
    
    func signUp(){
        // validate password
        if model.firstPassword != model.secondPassword{
            view?.passwordsAreNotEqual()
            return
        }
        
        if !stringValidation.validatePasswordsString(model.firstPassword, model.secondPassword){
            view?.passwordsNotValid()
            return
        }
        
        Task{
            do {
                if try await authNetworkService.signUp(email: model.email, password:model.secondPassword){
                    
                    self.login()
                    
                }else{
                    DispatchQueue.main.async {
                        self.view?.unknownError()
                    }
                }
                
            } catch customErrorAuth.emailExist{
                DispatchQueue.main.async {
                    self.view?.unknownError()
                }
            } catch  customErrorAuth.weakPassword{
                DispatchQueue.main.async {
                    self.view?.passwordsNotValid()
                }
                
            } catch customErrorAuth.unknowmError{
                DispatchQueue.main.async {
                    self.view?.unknownError()
                }
            }
        }
    }
    
    // MARK: - signUp
    public func signUp(email:String, password:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.signUp(email: email, password: password) { isSignIn, error in
            // check errors from api
            if error != nil{
                completion(false, error)
            }
            if isSignIn{
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
            
            let me = UserRealm(localId: self.keychainService.getLocalId()!, firstName: response!.first_name, secondName: response!.last_name, email: response!.email, phone: response!.phone, birthday: Date.dateStringToDate(dateString: response!.birthday_date))
            
            self.usersRealmService.setUserInfo(user: me)

            self.keychainService.setCompanyLocalId(companyLocalId: response!.company_id)
            self.keychainService.setCompanyName(companyName: response!.company_name)
            
            completion(true, nil)
            
        }
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
}
