//
//  EmployeePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation

protocol EmployeeViewProtocol:AnyObject{
    func setImage(imageData:Data)
    func changeLevelSuccess()
    func changeLevelError()
}

protocol EmployeePresenterProtocol:AnyObject{
    init(view:EmployeeViewProtocol, user:UsersModel)
    
    func getAccessLevel(_ key:AccessLevelKeys)->Bool
    
    
}
class EmployeePresenter:EmployeePresenterProtocol{
    weak var view:EmployeeViewProtocol?
    
    var user:UsersModel
    
    let apiUserData:ApiManagerUserDataProtocol = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    let keychain = KeychainService()
    let userRealmService = UsersRealmService()
    
    required init(view:EmployeeViewProtocol, user:UsersModel) {
        self.view = view
        self.user = user
    }
    
    func getAccessLevel(_ key:AccessLevelKeys)->Bool{
        userRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
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
    
    public func getLocalID() -> String{
        return keychain.getLocalId() ?? ""
    }
    
    public func getCompanyName()->String{
        keychain.getCompanyName() ?? ""
    }
    
    public func updateAccessLevel(accessLevel:UsersModel.AccessLevel, value:Bool){
        
        var newEmployee = self.user
        
        switch accessLevel {
        case .readCompanyEmployee:
            newEmployee.accessLevels.readCompanyEmployee = value
        case .readLocalIdCompany:
            newEmployee.accessLevels.readLocalIdCompany = value
        case .readGeneralCompanyInformation:
            newEmployee.accessLevels.readGeneralCompanyInformation = value
        case .writeGeneralCompanyInformation:
            newEmployee.accessLevels.writeGeneralCompanyInformation = value
        case .canChangeAccessLevel:
            newEmployee.accessLevels.canChangeAccessLevel = value
        case .isOwner:
            newEmployee.accessLevels.isOwner = value
        case .canReadTourList:
            newEmployee.accessLevels.canReadTourList = value
        case .canWriteTourList:
            newEmployee.accessLevels.canWriteTourList = value
        case .isGuide:
            newEmployee.accessLevels.isGuide = value
        }
        
        let jsonData = SendUpdateUserAccessLevel(
            token: keychain.getAcessToken() ?? "",
            company_id: keychain.getCompanyLocalId() ?? "",
            target_uid: newEmployee.localId,
            can_change_access_level: newEmployee.accessLevels.canChangeAccessLevel,
            can_read_tour_list: newEmployee.accessLevels.canReadTourList,
            can_write_tour_list: newEmployee.accessLevels.canWriteTourList,
            is_guide: newEmployee.accessLevels.isGuide,
            read_company_employee: newEmployee.accessLevels.readCompanyEmployee,
            read_general_company_information: newEmployee.accessLevels.readGeneralCompanyInformation,
            read_local_id_company: newEmployee.accessLevels.readLocalIdCompany,
            write_general_company_information: newEmployee.accessLevels.writeGeneralCompanyInformation
        )
        
        Task{
            do{
                if try await apiCompany.updateUserAccessLevel(jsonData){
                    DispatchQueue.main.async {
                        switch accessLevel {
                        case .readCompanyEmployee:
                            self.user.accessLevels.readCompanyEmployee = value
                        case .readLocalIdCompany:
                            self.user.accessLevels.readLocalIdCompany = value
                        case .readGeneralCompanyInformation:
                            self.user.accessLevels.readGeneralCompanyInformation = value
                        case .writeGeneralCompanyInformation:
                            self.user.accessLevels.writeGeneralCompanyInformation = value
                        case .canChangeAccessLevel:
                            self.user.accessLevels.canChangeAccessLevel = value
                        case .isOwner:
                            self.user.accessLevels.isOwner = value
                        case .canReadTourList:
                            self.user.accessLevels.canReadTourList = value
                        case .canWriteTourList:
                            self.user.accessLevels.canWriteTourList = value
                        case .isGuide:
                            self.user.accessLevels.isGuide = value
                        }
                        
                        self.view?.changeLevelSuccess()
                        self.userRealmService.updateUserAccessLevel(
                            localId: self.user.localId,
                            accessLevels: UserAccessLevelRealm(
                                readCompanyEmployee: self.user.accessLevels.readCompanyEmployee,
                                readLocalIdCompany: self.user.accessLevels.readLocalIdCompany,
                                readGeneralCompanyInformation: self.user.accessLevels.readGeneralCompanyInformation,
                                writeGeneralCompanyInformation: self.user.accessLevels.writeGeneralCompanyInformation,
                                canChangeAccessLevel: self.user.accessLevels.canChangeAccessLevel,
                                isOwner: self.user.accessLevels.isOwner,
                                canReadTourList: self.user.accessLevels.canReadTourList,
                                canWriteTourList: self.user.accessLevels.canWriteTourList,
                                isGuide: self.user.accessLevels.isGuide
                            )
                        )
                    }
                }
            }catch{
                
                DispatchQueue.main.async {
                    self.view?.changeLevelError()
                }
                
            }
        }

    }
    
    
}
