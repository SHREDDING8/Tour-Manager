//
//  ChangePasswordPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation

protocol ChangePasswordViewProtocol:AnyObject, BaseViewControllerProtocol{
    func passwordsAreNotTheSame()
    func weakPassword()
    func passwordUpdated()
}

protocol ChangePasswordPresenterProtocol:AnyObject{
    init(view:ChangePasswordViewProtocol)
    
    var passwords:[String:String] { get set }
    
    func updatePassword()
    
}

class ChangePasswordPresenter:ChangePasswordPresenterProtocol{
    weak var view:ChangePasswordViewProtocol?
    
    let validation = StringValidation()
    
    let keychain = KeychainService()
    let apiAuth = ApiManagerAuth()
    let usersRealm = UsersRealmService()
    
    var passwords:[String:String] = [
        "oldPassword": "",
        "newPassword": "",
        "secondNewPassword": "",
    ]
    
    required init(view:ChangePasswordViewProtocol) {
        self.view = view
    }
    
    public func updatePassword(){
        if passwords["newPassword"] != passwords["secondNewPassword"]{
            view?.passwordsAreNotTheSame()
            return
        }
        if !validation.validatePasswordsString(passwords["newPassword"] ?? "", passwords["secondNewPassword"] ?? ""){
            view?.weakPassword()
            return
        }
        
        let email = usersRealm.getUserInfo(localId: keychain.getLocalId() ?? "")?.email ?? ""
        self.view?.setLoading()
        self.view?.showLoadingView()
        Task{
            do{
                if try await self.apiAuth.updatePassword(email: email, oldPassword:passwords["oldPassword"] ?? "", newPassword: passwords["newPassword"] ?? ""){
                    DispatchQueue.main.async {
                        self.view?.passwordUpdated()
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
                self.view?.stopLoading()
                self.view?.stopLoadingView()
            }
            

        }
        
    }
}
