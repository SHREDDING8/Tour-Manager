//
//  ChangePasswordPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation

protocol ChangePasswordViewProtocol:AnyObject{
    
}

protocol ChangePasswordPresenterProtocol:AnyObject{
    init(view:ChangePasswordViewProtocol)
    
    func updatePassword(oldPassword:String, newPassword:String,completion: @escaping (Bool, customErrorAuth?)->Void )
}

class ChangePasswordPresenter:ChangePasswordPresenterProtocol{
    weak var view:ChangePasswordViewProtocol?
    
    let keychain = KeychainService()
    let apiAuth = ApiManagerAuth()
    let usersRealm = UsersRealmService()
    
    required init(view:ChangePasswordViewProtocol) {
        self.view = view
    }
    
    public func updatePassword(oldPassword:String, newPassword:String,completion: @escaping (Bool, customErrorAuth?)->Void ){
        let email = usersRealm.getUserInfo(localId: keychain.getLocalId() ?? "")?.email ?? ""
        self.apiAuth.updatePassword(email: email, oldPassword: oldPassword, newPassword: newPassword) { isUpdated, error in
            if error != nil{
                completion(false,error)
                return
            }
            completion(true,nil)
        }
    }
}
