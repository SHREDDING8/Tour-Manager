//
//  EmployeePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation

protocol EmployeeViewProtocol:AnyObject{
    
}

protocol EmployeePresenterProtocol:AnyObject{
    init(view:EmployeeViewProtocol)
}
class EmployeePresenter:EmployeePresenterProtocol{
    weak var view:EmployeeViewProtocol?
    
    let apiUserData = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    let keychain = KeychainService()
    let userRealmService = UsersRealmService()
    
    required init(view:EmployeeViewProtocol) {
        self.view = view
    }
    
    public func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void){
        
        self.apiUserData.downloadProfilePhoto(token: keychain.getAcessToken() ?? "", localId: localId) { isDownloaded, data, error in
            
            completion(data,error)
        }
    }
    
    public func getAccessLevel(localId:String, rule:AccessLevelKeys) -> Bool{
        return userRealmService.getUserAccessLevel(localId: localId, rule)
    }
    
    public func getLocalID() -> String{
        return keychain.getLocalId() ?? ""
    }
    
    public func updateAccessLevel(employe:User, accessLevel:User.AccessLevelEnum, value:Bool, completion: @escaping (Bool, customErrorCompany?)->Void ){
        
        employe.accessLevel[accessLevel] = value
        
        let jsonData = SendUpdateUserAccessLevel(
            token: keychain.getAcessToken() ?? "",
            company_id: keychain.getCompanyLocalId() ?? "",
            target_uid: employe.getLocalID() ?? "",
            can_change_access_level: employe.getAccessLevel(rule: .canChangeAccessLevel),
            can_read_tour_list: employe.getAccessLevel(rule: .canReadTourList),
            can_write_tour_list: employe.getAccessLevel(rule: .canWriteTourList),
            is_guide: employe.getAccessLevel(rule: .isGuide),
            read_company_employee: employe.getAccessLevel(rule: .readCompanyEmployee),
            read_general_company_information: employe.getAccessLevel(rule: .readGeneralCompanyInformation),
            read_local_id_company: employe.getAccessLevel(rule: .readLocalIdCompany),
            write_general_company_information: employe.getAccessLevel(rule: .writeGeneralCompanyInformation)
        )
        
        apiCompany.updateUserAccessLevel(jsonData) { isUpdated, error in
            completion(isUpdated,error)
        }
        
    }
    
    
}
