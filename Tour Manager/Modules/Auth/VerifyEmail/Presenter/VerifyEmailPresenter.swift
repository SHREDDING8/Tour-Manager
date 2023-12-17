//
//  VerifyEmailPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol VerifyEmailViewProtocol:AnyObject, BaseViewControllerProtocol{
    func emailSended()
    func emailVerifyed()
    func goToMain()
}

protocol VerifyEmailPresenterProtocol:AnyObject{
    init(view:VerifyEmailViewProtocol, loginData:loginData)
    
    var loginData:loginData { get }
    
    func sendVerifyEmail()
    func confirmTapped()
}
final class VerifyEmailPresenter:VerifyEmailPresenterProtocol{
    weak var view:VerifyEmailViewProtocol?
    
    var loginData:loginData
    
    let keychainService = KeychainService()
    let usersRealmService = UsersRealmService()
    let authNetworkService:ApiManagerAuthProtocol = ApiManagerAuth()
    let userDataNetworkService:ApiManagerUserDataProtocol = ApiManagerUserData()
    
    required init(view:VerifyEmailViewProtocol, loginData:loginData) {
        self.view = view
        self.loginData = loginData
    }
    
    func sendVerifyEmail(){
        view?.showLoadingView()
        view?.setLoading()
        Task{
            do{
                if try await authNetworkService.sendVerifyEmail(email: loginData.email, password: loginData.firstPassword){
                    DispatchQueue.main.async {
                        self.view?.emailSended()
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
    
    func confirmTapped(){
        view?.showLoadingView()
        view?.setLoading()
        Task{
            do {
                let loginResult = try await self.authNetworkService.logIn(email: loginData.email, password: loginData.firstPassword, deviceToken: keychainService.getDeviceToken() ?? "")
                
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
                    if err == .userDataNotFound{
                        DispatchQueue.main.async {
                            self.view?.emailVerifyed()
                        }
                        
                    }else{
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
    
}
