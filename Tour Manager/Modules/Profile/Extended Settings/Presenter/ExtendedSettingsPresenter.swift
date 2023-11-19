//
//  ExtendedSettingsPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import Foundation

protocol ExtendedSettingsViewProtocol:AnyObject{
    
}

protocol ExtendedSettingsPresenterProtocol:AnyObject{
    init(view:ExtendedSettingsViewProtocol)
    
    func revokeAllDevices()
    func deleteAccount()
    func deleteCompany()
    func isOwner()->Bool
    
    func getFullName()->String
    func getCompanyName()->String
    
}
class ExtendedSettingsPresenter:ExtendedSettingsPresenterProtocol{
    weak var view:ExtendedSettingsViewProtocol?
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    
    required init(view:ExtendedSettingsViewProtocol) {
        self.view = view
    }
    
    func revokeAllDevices(){
        
    }
    
    func deleteAccount(){
        
    }
    
    func deleteCompany(){
        
    }
    
    func isOwner()->Bool{
        usersRealmService.getUserAccessLevel(localId: keychainService.getLocalId() ?? "", .isOwner)
    }
    
    func getFullName()->String{
        let info = usersRealmService.getUserInfo(localId: keychainService.getLocalId() ?? "")
        
        return (info?.firstName ?? "") + " " + (info?.secondName ?? "")
    }
    func getCompanyName()->String{
        keychainService.getCompanyName() ?? ""
    }
}
