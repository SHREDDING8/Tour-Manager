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
    
    required init(view:MainTabBarViewProtocol) {
        self.view = view
    }
    
    public func getAccessLevelFromApi(completion: @escaping (Bool, customErrorCompany?)->Void){
        
        self.apiCompany.getCurrentAccessLevel(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "") { accessLevel, error in
            if error != nil{
                completion(false,error)
            }
            
            if accessLevel != nil{
                self.keychain.setAccessLevel(key: .readCompanyEmployee, value: accessLevel?.read_company_employee ?? false)
                self.keychain.setAccessLevel(key: .readLocalIdCompany, value: accessLevel?.read_local_id_company ?? false)
                self.keychain.setAccessLevel(key: .readGeneralCompanyInformation, value: accessLevel?.read_general_company_information ?? false)
                self.keychain.setAccessLevel(key: .writeGeneralCompanyInformation, value: accessLevel?.write_general_company_information ?? false)
                self.keychain.setAccessLevel(key: .canChangeAccessLevel, value: accessLevel?.can_change_access_level ?? false)
                self.keychain.setAccessLevel(key: .isOwner, value: accessLevel?.is_owner ?? false)
                
                self.keychain.setAccessLevel(key: .canReadTourList, value: accessLevel?.can_read_tour_list ?? false)
                self.keychain.setAccessLevel(key: .canWriteTourList, value: accessLevel?.can_write_tour_list ?? false)
                self.keychain.setAccessLevel(key: .isGuide, value: accessLevel?.is_guide ?? false)
                
                completion(true,nil)
            }
        }
    }
}
