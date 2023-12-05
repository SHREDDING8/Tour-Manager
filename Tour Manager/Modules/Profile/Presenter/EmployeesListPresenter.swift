//
//  employeesListPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation
import UIKit

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
    
    let employeeNetworkService:EmployeeNetworkServiceProtocol = EmployeeNetworkService()
    let keychain = KeychainService()
    
    let usersNetworkService:ApiManagerUserDataProtocol = ApiManagerUserData()
    
    let usersRealmService = UsersRealmService()
    
    required init(view:EmployeesListViewProtocol) {
        self.view = view
    }
    
    func getUsersFromRealm(){
        let realmUsers = usersRealmService.getAllUsers()
        self.users = []
        
        for user in realmUsers{
            var image:UIImage? = nil
            if let imageData = user.image{
                image = UIImage(data: imageData)
            }
            
            let newUserModel = UsersModel(
                localId: user.localId,
                firstName: user.firstName,
                secondName: user.secondName,
                email: user.email ?? "",
                phone: user.phone ?? "",
                birthday: user.birthday ?? Date.now,
                image: image,
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
                let jsonUsers = try await self.employeeNetworkService.getCompanyUsers()
                
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
                    
                    
                    // добавить фото как в petConnect
                    do{
                        let imageData = try await self.usersNetworkService.downloadProfilePhoto(localId: jsonUser.uid)
                        
                        DispatchQueue.main.sync {
                            self.usersRealmService.updateImage(id: jsonUser.uid, image: imageData)
                        }
                        
                    }catch{
                        
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
