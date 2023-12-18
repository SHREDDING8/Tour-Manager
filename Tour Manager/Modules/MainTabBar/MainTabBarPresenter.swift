//
//  mainTabBarPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol MainTabBarViewProtocol:AnyObject{
    func updateControllers()
    
    func showError(error:NetworkServiceHelper.NetworkError)
}

protocol MainTabBarPresenterProtocol:AnyObject{
    init(view:MainTabBarViewProtocol)
    
    func getAccessLevelFromApi()
    
    func isUserGuide() -> Bool
    func isUserCanReadAllTours() -> Bool
    
    
}
final class MainTabBarPresenter:MainTabBarPresenterProtocol{
    weak var view:MainTabBarViewProtocol?
    
    let keychain = KeychainService()
    let employeeNetworkService:EmployeeNetworkServiceProtocol = EmployeeNetworkService()
    
    let userRealmService = UsersRealmService()
    
    required init(view:MainTabBarViewProtocol) {
        self.view = view
    }
    
    public func getAccessLevelFromApi(){
        Task{
            do{
                let accessLevel = try await self.employeeNetworkService.getCurrentCompanyUserAccessLevels()
                
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
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    DispatchQueue.main.async {
                        self.view?.showError(error: err)
                    }
                    
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
