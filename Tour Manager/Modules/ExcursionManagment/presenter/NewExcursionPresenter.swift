//
//  NewExcursionPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation

protocol NewExcursionViewProtocol:AnyObject{
    
}

protocol NewExcursionPresenterProtocol:AnyObject{
    init(view:NewExcursionViewProtocol)
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    
    func updateExcursion(excursion:Excursion, oldDate:Date, completion: @escaping (Bool, customErrorExcursion?)->Void)
    
    func createNewExcursion(excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void)
    
    func deleteExcursion(excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void)
    
    func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void)
}

class NewExcursionPresenter:NewExcursionPresenterProtocol{
    weak var view:NewExcursionViewProtocol?
    
    let keychain = KeychainService()
    let usersRealmService = UsersRealmService()
    
    let apiManagerExcursions = ApiManagerExcursions()
    
    let apiUserData = ApiManagerUserData()
    
    required init(view:NewExcursionViewProtocol) {
        self.view = view
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    public func updateExcursion(excursion:Excursion, oldDate:Date, completion: @escaping (Bool, customErrorExcursion?)->Void){
        
        apiManagerExcursions.updateExcursion(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", excursion: excursion, oldDate: oldDate) { isUpdated, error in
            completion(isUpdated,error)
        }
    }
    
    public func createNewExcursion(excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void){

        apiManagerExcursions.AddNewExcursion(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "" ,excursion: excursion) { isAdded, error in
            completion(isAdded,error)
        }
    }
    
    public func deleteExcursion(excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void){
        apiManagerExcursions.deleteExcursion(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", date: excursion.dateAndTime.birthdayToString(), excursionId: excursion.localId) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void){
        
        self.apiUserData.downloadProfilePhoto(token: keychain.getAcessToken() ?? "", localId: localId) { isDownloaded, data, error in
            
            completion(data,error)
        }
    }
}
