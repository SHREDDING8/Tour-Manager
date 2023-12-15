//
//  LoginViewPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol LoginViewProtocol:AnyObject, BaseViewControllerProtocol{
    func modeChanged(newMode:LoginPresenter.PageModes)
    
    func resetSuccess(email:String)
    
    func emailIsNotVerifyed()
    
    func wrongEmail()
    
    func passwordsNotValid()
    func passwordsAreNotEqual()
    
    func goToVerifyVC(loginData:loginData)
    func goToMain()
    func goToAddingPersonalData()
    
    
}

protocol LoginPresenterProtocol:AnyObject{
    init(view:LoginViewProtocol)
    
    var model:loginData { get }
    
    func changeMode()
    
    func setEmail(email:String)
    func setPassword(password:String)
    func setConfirmPassword(password:String)
    
    func isValidEmail(email:String) -> Bool
    
    func removeAllData()
    
    func resetPassword(email:String)
    
    func loginButtonTapped()
    
    func sendVerifyEmail()
}

class LoginPresenter:LoginPresenterProtocol{
    
    enum PageModes{
        case login
        case signUp
    }
    
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
    
    var pageMode:PageModes = .login
    
    required init(view:LoginViewProtocol) {
        self.view = view
    }
    
    func changeMode(){
        pageMode = pageMode == .login ? .signUp : .login
        
        model.clearPasswords()
        view?.modeChanged(newMode: pageMode)
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
        view?.showLoadingView()
        view?.setLoading()
        Task{
            do{
                if try await authNetworkService.resetPassword(email: email){
                    DispatchQueue.main.async {
                        self.view?.resetSuccess(email:email)
                    }
                }
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    DispatchQueue.main.async {
                        self.view?.showError(error: err)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopLoadingView()
                self.view?.stopLoading()
            }
        }
    }
    
    func loginButtonTapped(){
        switch pageMode {
        case .login:
            self.login()
        case .signUp:
            self.signUp()
        }
    }
    
    func login(){
        view?.showLoadingView()
        view?.setLoading()
        Task{
            do {
                let loginResult = try await self.authNetworkService.logIn(email: model.email, password: model.firstPassword, deviceToken: keychainService.getDeviceToken() ?? "")
                
                keychainService.setLocalId(id: loginResult.localId)
                keychainService.setAcessToken(token: loginResult.token)
                keychainService.setRefreshToken(token: loginResult.refreshToken)
                
                let userDataResult = try await self.userDataNetworkService.getUserInfo()
                
                DispatchQueue.main.async {
                    
                    let me = UserRealm(localId: self.keychainService.getLocalId()!, firstName: userDataResult.first_name, secondName: userDataResult.last_name, email: userDataResult.email, phone: userDataResult.phone, birthday: Date.dateStringToDate(dateString: userDataResult.birthday_date), imageIDs: userDataResult.profile_pictures)
                    
                    self.usersRealmService.setUserInfo(user: me)
                    
                    self.keychainService.setCompanyLocalId(companyLocalId: userDataResult.company_id)
                    self.keychainService.setCompanyName(companyName: userDataResult.company_name)
                    
                    self.view?.goToMain()
                }
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    if err == .emailIsNotVerified{
                        DispatchQueue.main.async {
                            self.view?.emailIsNotVerifyed()
                        }
                    }else if err == .userDataNotFound{
                        DispatchQueue.main.async {
                            self.view?.goToAddingPersonalData()
                        }
                        
                    }
                    else{
                        self.view?.showError(error: err)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopLoadingView()
                self.view?.stopLoading()
            }
            
        }
    }
    
    func sendVerifyEmail(){
        view?.showLoadingView()
        view?.setLoading()
        Task{
            do{
                if try await authNetworkService.sendVerifyEmail(email: model.email, password: model.firstPassword){
                    DispatchQueue.main.async {
                        self.view?.goToVerifyVC(loginData: self.model)
                    }
                    
                }
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.view?.stopLoadingView()
            self.view?.stopLoading()
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
        
        view?.setLoading()
        view?.showLoadingView()
        Task{
            do {
                if try await authNetworkService.signUp(email: model.email, password:model.secondPassword){
                    DispatchQueue.main.async {
                        self.login()
                    }
                }
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopLoading()
                self.view?.stopLoadingView()
            }
        }
    }
    
    // MARK: - logIn
    
    
}
