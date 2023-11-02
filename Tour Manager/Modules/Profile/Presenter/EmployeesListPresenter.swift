//
//  employeesListPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation

protocol EmployeesListViewProtocol:AnyObject{
    func updateUsersList()
    func unknownError()
}

protocol EmployeesListPresenterProtocol:AnyObject{
    
    var users:[UsersModel] { get }
    
    init(view:EmployeesListViewProtocol)
    
    func getUsersFromRealm()
    func getUsersFromServer()
}

class EmployeesListPresenter:EmployeesListPresenterProtocol{
    weak var view:EmployeesListViewProtocol?
    
    var users:[UsersModel] = []
    
    let apiCompany:ApiManagerCompanyProtocol = ApiManagerCompany()
    let keychain = KeychainService()
    
    let usersRealmService = UsersRealmService()
    
    required init(view:EmployeesListViewProtocol) {
        self.view = view
    }
    
    func getUsersFromRealm(){
        let realmUsers = usersRealmService.getAllUsers()
        self.users = []
        
        for user in realmUsers{
            let newUserModel = UsersModel(
                localId: user.localId,
                firstName: user.firstName,
                secondName: user.secondName,
                email: user.email ?? "",
                phone: user.phone ?? "",
                birthday: user.birthday ?? Date.now,
                accessLevels: UsersModel.UserAccessLevels(
                    readCompanyEmployee: user.accesslLevels?.readCompanyEmployee ?? false,
                    readLocalIdCompany: user.accesslLevels?.readLocalIdCompany ?? false,
                    readGeneralCompanyInformation: user.accesslLevels?.readGeneralCompanyInformation ?? false,
                    writeGeneralCompanyInformation: user.accesslLevels?.writeGeneralCompanyInformation ?? false,
                    canChangeAccessLevel: user.accesslLevels?.canChangeAccessLevel ?? false,
                    isOwner: user.accesslLevels?.isOwner ?? false,
                    canReadTourList: user.accesslLevels?.canReadTourList ?? false,
                    canWriteTourList: user.accesslLevels?.canWriteTourList ?? false,
                    isGuide: user.accesslLevels?.isGuide ?? false))
            
            self.users.append(newUserModel)
        }
        view?.updateUsersList()
    }
    
    func getUsersFromServer(){
        Task{
            do {
                let jsonUsers = try await self.apiCompany.getCompanyUsers()
                
                for jsonUser in jsonUsers {
                    let realmUser = UserRealm(
                        localId: jsonUser.uid,
                        firstName: jsonUser.firstName,
                        secondName: jsonUser.lastName,
                        email: jsonUser.email,
                        phone: jsonUser.phone,
                        birthday: Date.birthdayFromString(dateString: jsonUser.birthdayDate),
                        accesslLevels: UserAccessLevelRealm(
                            readCompanyEmployee: jsonUser.accessLevels.readCompanyEmployee,
                            readLocalIdCompany: jsonUser.accessLevels.readLocalIDCompany,
                            readGeneralCompanyInformation: jsonUser.accessLevels.readGeneralCompanyInformation,
                            writeGeneralCompanyInformation: jsonUser.accessLevels.writeGeneralCompanyInformation,
                            canChangeAccessLevel: jsonUser.accessLevels.canChangeAccessLevel,
                            isOwner: jsonUser.accessLevels.isOwner,
                            canReadTourList: jsonUser.accessLevels.canReadTourList,
                            canWriteTourList: jsonUser.accessLevels.canWriteTourList,
                            isGuide: jsonUser.accessLevels.isGuide))
                    
                    DispatchQueue.main.sync {
                        usersRealmService.setUserInfo(user: realmUser)
                    }
                    
                }
                DispatchQueue.main.async {
                    self.getUsersFromRealm()
                }
                
            } catch customErrorCompany.unknowmError{
                DispatchQueue.main.async {
                    self.view?.unknownError()
                }
            }
        }
    }
    
}
