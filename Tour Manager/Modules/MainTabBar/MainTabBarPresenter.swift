//
//  mainTabBarPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol MainTabBarViewProtocol:AnyObject{
    
}

protocol MainTabBarPresenterProtocol:AnyObject{
    init(view:MainTabBarViewProtocol)
    
    func getAccessLevelFromApi(completion: @escaping (Bool, customErrorCompany?)->Void)
    
}
class MainTabBarPresenter:MainTabBarPresenterProtocol{
    weak var view:MainTabBarViewProtocol?
    
    let keychain = KeychainService()
    let apiCompany = ApiManagerCompany()
    
    let userRealmService = UsersRealmService()
    
    required init(view:MainTabBarViewProtocol) {
        self.view = view
    }
    
    public func getAccessLevelFromApi(completion: @escaping (Bool, customErrorCompany?)->Void){
        
        self.apiCompany.getCurrentAccessLevel(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "") { accessLevel, error in
            if error != nil{
                completion(false,error)
            }
            
            if accessLevel != nil{
                
                let accessLevels = UserAccessLevelRealm(
                    readCompanyEmployee: accessLevel?.read_company_employee ?? false,
                    readLocalIdCompany: accessLevel?.read_local_id_company ?? false,
                    readGeneralCompanyInformation: accessLevel?.read_general_company_information ?? false,
                    writeGeneralCompanyInformation: accessLevel?.write_general_company_information ?? false,
                    canChangeAccessLevel: accessLevel?.can_change_access_level ?? false,
                    isOwner: accessLevel?.is_owner ?? false,
                    canReadTourList: accessLevel?.can_read_tour_list ?? false,
                    canWriteTourList: accessLevel?.can_write_tour_list ?? false,
                    isGuide: accessLevel?.is_guide ?? false)
                                
                self.userRealmService.updateUserAccessLevel(localId: self.keychain.getLocalId() ?? "", accessLevels: accessLevels)
                                
                completion(true,nil)
            }
        }
    }
}
