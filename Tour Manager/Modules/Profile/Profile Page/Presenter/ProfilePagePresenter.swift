//
//  ProfilePagePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.08.2023.
//

import Foundation
import UIKit

protocol ProfileViewProtocol:AnyObject{
    func updateImage(at indexPath:IndexPath, image:UIImage)
    
    func deletePhotoSuccess()
    func deletePhotoError()
    func uploadSuccess(image:UIImage)
    func uploadError()
    
    func updateInfoError()
    func updateInfoSuccess()
    
    func updateCompanyInfoError()
    func updateCompanyInfoSuccess()
    
    func logoutSuccess()
    func logoutError()
    
    func loadUserInfoFromServer()
}

protocol ProfilePagePresenterProtocol:AnyObject{
    init(view:ProfileViewProtocol)
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    
    func getUserInfoFromServer()
    
    func getCompanyName() -> String
    func getCompanyId() -> String
        
    func getFirstName() ->String
    func getSecondName() ->String
    func getFullName() ->String
    func getBirthday() -> String
    func getPhone() -> String
    func getEmail() -> String
    
    func getNumberOfPhotos() -> Int
    func getProfilePhoto(indexPath:IndexPath) -> UIImage?
    
    func uploadProfilePhoto(image:UIImage)
    func deleteProfilePhoto(index:Int)
    
    func updatePersonalData(updateField: UserDataFields,value:String) 
    
    func updateCompanyInfo(companyName:String)
    
    func logOut()
    
}
class ProfilePagePresenter:ProfilePagePresenterProtocol{
    weak var view:ProfileViewProtocol?
    
    let keychain:KeychainServiceProtocol = KeychainService()
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    let imageService:ImagesRealmServiceProtocol = ImagesRealmService()
    
    let apiUserData = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    let employeeNetworkService:EmployeeNetworkServiceProtocol = EmployeeNetworkService()
    let apiAuth = ApiManagerAuth()
    
    required init(view:ProfileViewProtocol) {
        self.view = view
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    public func getCompanyName() -> String{
        return keychain.getCompanyName() ?? ""
    }
    
    public func getCompanyId() -> String{
        return keychain.getCompanyLocalId() ?? ""
    }
    
    func getNumberOfPhotos() -> Int{
        self.usersRealmService.getUserInfo(localId: self.keychain.getLocalId() ?? "" )?.imageIDs.count ?? 0
    }
    
    func getUserInfoFromServer(){
        Task{
            do{
                let newInfo = try await apiUserData.getUserInfo()
                let newAccessLevels = try await employeeNetworkService.getCurrentCompanyUserAccessLevels()
                
                let newUserRealm = UserRealm(
                    localId: keychain.getLocalId() ?? "",
                    firstName: newInfo.first_name,
                    secondName: newInfo.last_name,
                    email: newInfo.email,
                    phone: newInfo.phone,
                    birthday: Date.birthdayFromString(dateString: newInfo.birthday_date),
                    imageIDs: newInfo.profile_pictures,
                    accesslLevels: UserAccessLevelRealm(
                        readCompanyEmployee: newAccessLevels.read_company_employee,
                        readLocalIdCompany: newAccessLevels.read_local_id_company,
                        readGeneralCompanyInformation: newAccessLevels.read_general_company_information,
                        writeGeneralCompanyInformation: newAccessLevels.write_general_company_information,
                        canChangeAccessLevel: newAccessLevels.can_change_access_level,
                        isOwner: newAccessLevels.is_owner,
                        canReadTourList: newAccessLevels.can_read_tour_list,
                        canWriteTourList: newAccessLevels.can_write_tour_list,
                        isGuide: newAccessLevels.is_guide
                    )
                )
                
                DispatchQueue.main.async {
                    self.usersRealmService.setUserInfo(user: newUserRealm)
                    self.view?.loadUserInfoFromServer()
                }
                
            }catch{
                print("catch")
            }
            
        }
    }
    
    func getProfilePhoto(indexPath:IndexPath) -> UIImage?{
        
        guard let userRealm = self.usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "") else { fatalError("Current User not found")}
                
        if indexPath.row < userRealm.imageIDs.count{
            if let imageData = imageService.getImage(by: userRealm.imageIDs[indexPath.row]){
                let image = UIImage(data: imageData)!
                return image
                
            }else{
                self.downloadProfilePhoto(indexPath: indexPath, pictureId: userRealm.imageIDs[indexPath.row])
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
                    self.view?.updateImage(at: indexPath, image: image)
                }
                
            } catch{
                
            }
            
        }
        
    }
    
    
    public func getFirstName() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.firstName ?? ""
    }
    public func getSecondName() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.secondName ?? ""
    }
    
    public func getFullName() ->String{
        let user = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")
        return (user?.firstName ?? "") + " " + (user?.secondName ?? "")
    }
    
    public func getBirthday() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.birthday?.birthdayToString() ?? ""
    }
    
    public func getPhone() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.phone ?? ""
    }
    
    public func getEmail() -> String{
        return usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.email ?? ""
    }
        
    public func logOut(){
        Task{
            do{
                if try await self.apiAuth.logOut(){
                    DispatchQueue.main.async {
                        self.view?.logoutSuccess()
                    }
                    
                }
            }catch{
                DispatchQueue.main.async {
                    self.view?.logoutError()
                }
            }
        }
        
    }
    
    
    public func uploadProfilePhoto(image:UIImage){
        Task{
            do{
                let newPictureId = try await self.apiUserData.uploadProfilePhoto(image:image)
                DispatchQueue.main.async {
                    self.usersRealmService.updateImage(userId: self.keychain.getLocalId() ?? "", pictureId: newPictureId)
                    self.imageService.setNewImage(id: newPictureId, image.pngData()!)
                    self.view?.uploadSuccess(image: image)
                }
                
                
            } catch{
                DispatchQueue.main.async {
                    self.view?.uploadError()
                }
                
            }
            
        }
    }
    
    public func deleteProfilePhoto(index:Int){
        
        if let imageId = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.imageIDs[index]{
            
            Task{
                do{
                    if try await self.apiUserData.deleteProfilePhoto(pictureId: imageId){
                        DispatchQueue.main.async {
                            self.usersRealmService.deleteImage(userId: self.keychain.getLocalId() ?? "", pictureId: imageId)
                            self.imageService.deleteImage(by: imageId)
                            self.view?.deletePhotoSuccess()
                        }
                    }
                }catch{
                    print("deleteError")
                }
                
            }
            
        }
        
        
    }
    
    public func updatePersonalData(updateField: UserDataFields,value:String) {
        Task{
            do{
                if try await self.apiUserData.updateUserInfo(updateField: updateField, value: value){
                    DispatchQueue.main.async {
                        if updateField == .birthdayDate{
                            self.usersRealmService.updateBirhday(localId: self.keychain.getLocalId() ?? "", date: Date.birthdayFromString(dateString: value))
                        }else{
                            self.usersRealmService.updateField(localId: self.keychain.getLocalId() ?? "", updateField: updateField, value: value)
                        }
                        
                        self.view?.updateInfoSuccess()
                    }
                    
                }
                
            } catch{
                DispatchQueue.main.async {
                    self.view?.updateInfoError()
                }
                
            }
        }
    }
    
    public func updateCompanyInfo(companyName:String){
        Task{
            do{
                if try await self.apiCompany.updateCompanyInfo(companyName:companyName){
                    DispatchQueue.main.async {
                        self.keychain.setCompanyName(companyName: companyName)
                        self.view?.updateCompanyInfoSuccess()
                    }
                    
                }
            } catch{
                DispatchQueue.main.async {
                    self.view?.updateCompanyInfoError()
                }
                
            }
        }
    }
    
}
