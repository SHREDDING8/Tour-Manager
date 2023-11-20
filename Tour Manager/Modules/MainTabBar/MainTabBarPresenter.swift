//
//  mainTabBarPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

// Cделать главный view controller где сделать фукнцию которая отвечает за refreshError

protocol MainTabBarViewProtocol:AnyObject{
    func unknownError()
    func updateControllers()
}

protocol MainTabBarPresenterProtocol:AnyObject{
    init(view:MainTabBarViewProtocol)
    
    func getAccessLevelFromApi()
    
    func isUserGuide() -> Bool
    func isUserCanReadAllTours() -> Bool
    
    
}
class MainTabBarPresenter:MainTabBarPresenterProtocol{
    weak var view:MainTabBarViewProtocol?
    
    let keychain = KeychainService()
    let apiCompany:ApiManagerCompanyProtocol = ApiManagerCompany()
    
    let userRealmService = UsersRealmService()
    
    required init(view:MainTabBarViewProtocol) {
        self.view = view
    }
    
    public func getAccessLevelFromApi(){
        Task{
            do{
                let accessLevel = try await self.apiCompany.getCurrentAccessLevel()
                
                DispatchQueue.main.async {
                    let accessLevels = UserAccessLevelRealm(
                        readCompanyEmployee: accessLevel.read_company_employee,
                        readLocalIdCompany: accessLevel.read_local_id_company,
                        readGeneralCompanyInformation: accessLevel.read_general_company_information,
                        writeGeneralCompanyInformation: accessLevel.write_general_company_information,
                        canChangeAccessLevel: accessLevel.can_change_access_level,
                        isOwner: accessLevel.is_owner,
                        canReadTourList: accessLevel.can_read_tour_list,
                        canWriteTourList: accessLevel.can_write_tour_list,
                        isGuide: accessLevel.is_guide)
                    
                    self.userRealmService.updateUserAccessLevel(localId: self.keychain.getLocalId() ?? "", accessLevels: accessLevels)
                    
                    
                    self.view?.updateControllers()
                }
                
            } catch customErrorCompany.unknowmError{
                DispatchQueue.main.async {
                    self.view?.unknownError()
                }
                
            }
            
        }
    }
    
    func isUserGuide() -> Bool{
        userRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", .isGuide)
    }
    
    func isUserCanReadAllTours() -> Bool{
        userRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", .canReadTourList)
    }
    
}
