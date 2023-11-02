//
//  EmployeePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation

protocol EmployeeViewProtocol:AnyObject{
    func setImage(imageData:Data)
}

protocol EmployeePresenterProtocol:AnyObject{
    init(view:EmployeeViewProtocol, user:UsersModel)
}
class EmployeePresenter:EmployeePresenterProtocol{
    weak var view:EmployeeViewProtocol?
    
    var user:UsersModel!
    
    let apiUserData:ApiManagerUserDataProtocol = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    let keychain = KeychainService()
    let userRealmService = UsersRealmService()
    
    required init(view:EmployeeViewProtocol, user:UsersModel) {
        self.view = view
        self.user = user
    }
    
    public func downloadProfilePhoto(localId:String){
        
        Task{
            do{
                let imageData = try await self.apiUserData.downloadProfilePhoto(localId: user.localId)
                view?.setImage(imageData: imageData)
            } catch{
                
            }
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
