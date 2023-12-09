//
//  EmployeePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation
import UIKit

protocol EmployeeViewProtocol:AnyObject{
    func updateImage(at indexPath:IndexPath, image:UIImage)
    func changeLevelSuccess()
    func changeLevelError()
    
    func loadUserInfoFromServer()
}

protocol EmployeePresenterProtocol:AnyObject{
    init(view:EmployeeViewProtocol, user:UsersModel)
    
    func getAccessLevel(_ key:AccessLevelKeys)->Bool
    
    func getNumberOfPhotos() -> Int
        
    func getProfilePhoto(indexPath:IndexPath) -> UIImage?
    
    func getUserInfoFromServer()
    
    
}

class EmployeePresenter:EmployeePresenterProtocol{
    weak var view:EmployeeViewProtocol?
    
    var user:UsersModel
    
    let apiUserData:ApiManagerUserDataProtocol = ApiManagerUserData()
    let employeeNetworkService:EmployeeNetworkService = EmployeeNetworkService()
    let keychain = KeychainService()
    let userRealmService = UsersRealmService()
    let imageService:ImagesRealmServiceProtocol = ImagesRealmService()
    
    required init(view:EmployeeViewProtocol, user:UsersModel) {
        self.view = view
        self.user = user
    }
    
    func getAccessLevel(_ key:AccessLevelKeys)->Bool{
        userRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    func getNumberOfPhotos() -> Int{
        self.userRealmService.getUserInfo(localId: self.user.localId)?.imageIDs.count ?? 0
    }
    
    func getProfilePhoto(indexPath:IndexPath) -> UIImage?{
        if indexPath.row < user.images.count{
            return user.images[indexPath.row].image
        }
        
        if let user = self.userRealmService.getUserInfo(localId: user.localId), indexPath.row < user.imageIDs.count{
            if let imageData = imageService.getImage(by: user.imageIDs[indexPath.row]){
                let image = UIImage(data: imageData)!
                self.user.images.append( (user.imageIDs[indexPath.row], image) )
                return image
                
            }else{
                self.downloadProfilePhoto(indexPath: indexPath, pictureId: user.imageIDs[indexPath.row])
            }
        }
        
        return nil
    }
    
    private func downloadProfilePhoto(indexPath:IndexPath, pictureId:String){
        Task{
            do{
                let imageData = try await self.apiUserData.downloadProfilePhoto(pictureId: pictureId)
                
                DispatchQueue.main.async {
                    self.imageService.setNewImage(id: pictureId, imageData)
                    let image = UIImage(data: imageData)!
                    self.user.images.append((pictureId, image))
                    self.view?.updateImage(at: indexPath, image: image)
                }
                
            } catch{
                
            }
            
        }
        
    }
    
    func loadPhotos(){
        var imageForDownload:[String] = []
        if let userImageIds = userRealmService.getUserInfo(localId: user.localId)?.imageIDs{
            for imageid in userImageIds {
                if imageService.getImage(by: imageid) == nil{
                    imageForDownload.append(imageid)
                }
            }
        }
    }
    
    func getUserInfoFromServer(){
        Task{
            do{
                let newInfo = try await employeeNetworkService.getEmployeeInfoById(employeeId: self.user.localId)
                let newUserRealm = UserRealm(
                    localId: self.user.localId,
                    firstName: newInfo.firstName,
                    secondName: newInfo.lastName,
                    email: newInfo.email,
                    phone: newInfo.phone,
                    birthday: Date.birthdayFromString(dateString: newInfo.birthdayDate),
                    imageIDs: newInfo.profilePictures,
                    accesslLevels: UserAccessLevelRealm(
                        readCompanyEmployee: newInfo.accessLevels.readCompanyEmployee,
                        readLocalIdCompany: newInfo.accessLevels.readLocalIDCompany,
                        readGeneralCompanyInformation: newInfo.accessLevels.readGeneralCompanyInformation,
                        writeGeneralCompanyInformation: newInfo.accessLevels.writeGeneralCompanyInformation,
                        canChangeAccessLevel: newInfo.accessLevels.canChangeAccessLevel,
                        isOwner: newInfo.accessLevels.isOwner,
                        canReadTourList: newInfo.accessLevels.canReadTourList,
                        canWriteTourList: newInfo.accessLevels.canWriteTourList,
                        isGuide: newInfo.accessLevels.isGuide
                    )
                )
                
                DispatchQueue.main.async {
                    self.userRealmService.setUserInfo(user: newUserRealm)
                    
                    var newImages:[(String, UIImage)] = []
                    
                    for id in newInfo.profilePictures{
                        if let imageData = self.imageService.getImage(by: id){
                            newImages.append((id, UIImage(data: imageData)!))
                        }
                    }
                    
                    self.user = UsersModel(
                        localId: newInfo.uid,
                        firstName: newInfo.firstName,
                        secondName: newInfo.lastName,
                        email: newInfo.email,
                        phone: newInfo.phone,
                        birthday: Date.birthdayFromString(dateString: newInfo.birthdayDate),
                        images: newImages,
                        accessLevels: UsersModel.UserAccessLevels(
                            readCompanyEmployee: newInfo.accessLevels.readCompanyEmployee,
                            readLocalIdCompany: newInfo.accessLevels.readLocalIDCompany,
                            readGeneralCompanyInformation: newInfo.accessLevels.readGeneralCompanyInformation,
                            writeGeneralCompanyInformation: newInfo.accessLevels.writeGeneralCompanyInformation,
                            canChangeAccessLevel: newInfo.accessLevels.canChangeAccessLevel,
                            isOwner: newInfo.accessLevels.isOwner,
                            canReadTourList: newInfo.accessLevels.canReadTourList,
                            canWriteTourList: newInfo.accessLevels.canWriteTourList,
                            isGuide: newInfo.accessLevels.isGuide
                        )
                    )
                    
                    self.view?.loadUserInfoFromServer()
                }
                
            }catch{
                print("catch")
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
                if try await employeeNetworkService.updateCompanyUserAccessLevel(employeeId: user.localId, jsonData){
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
