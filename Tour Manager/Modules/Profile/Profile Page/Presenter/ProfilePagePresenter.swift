//
//  ProfilePagePresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.08.2023.
//

import Foundation
import UIKit

protocol ProfileViewProtocol:AnyObject{
    func setProfilePhoto(image:UIImage)
    
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
}

protocol ProfilePagePresenterProtocol:AnyObject{
    init(view:ProfileViewProtocol)
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    func getCompanyName() -> String
    func getCompanyId() -> String
    
    func getProfilePhoto()
    func getProfilePhotoFromRealm() -> UIImage
    func getFirstName() ->String
    func getSecondName() ->String
    func getFullName() ->String
    func getBirthday() -> String
    func getPhone() -> String
    func getEmail() -> String
    
    func uploadProfilePhoto(image:UIImage)
    func deleteProfilePhoto()
    
    func updatePersonalData(updateField: UserDataFields,value:String) 
    
    func updateCompanyInfo(companyName:String)
    
    func logOut()
    
}
class ProfilePagePresenter:ProfilePagePresenterProtocol{
    weak var view:ProfileViewProtocol?
    
    let keychain = KeychainService()
    let usersRealmService = UsersRealmService()
    let imageService:ImagesRealmServiceProtocol = ImagesRealmService()
    
    let apiUserData = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
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
    
    public func getProfilePhoto(){
        
        if let imageId = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.imageIDs.first{
            if let imageData = imageService.getImage(by: imageId){
                view?.setProfilePhoto(image: UIImage(data: imageData)!)
                return
            }else{
                self.downloadProfilePhoto(pictureId: imageId)
            }
        }
        
        view?.setProfilePhoto(image: UIImage(resource: .noProfilePhoto))
        
    }
    
    public func getProfilePhotoFromRealm() -> UIImage{
        
        if let imageId = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.imageIDs.first{
            if let imageData = imageService.getImage(by: imageId){
                return UIImage(data: imageData)!
            }
        }
        
        return UIImage(resource: .noProfilePhoto)
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
    
    
    public func deleteCurrentUser(completion: @escaping (Bool, customErrorUserData?)->Void){

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
    
    public func DeleteCompany(completion: @escaping (Bool, customErrorCompany?) ->Void){
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
    
    private func downloadProfilePhoto(pictureId:String){
        Task{
            do{
                let imageData = try await self.apiUserData.downloadProfilePhoto(pictureId: pictureId)
                
                DispatchQueue.main.async {
                    self.usersRealmService.updateImage(userId: self.keychain.getLocalId() ?? "", pictureId: pictureId)
                    self.imageService.setNewImage(id: pictureId, imageData)
                    self.view?.setProfilePhoto(image: UIImage(data: imageData)!)
                }

            }catch{
                
            }
        }
    }
    
    public func deleteProfilePhoto(){
            
                if let imageId = usersRealmService.getUserInfo(localId: keychain.getLocalId() ?? "")?.imageIDs.first{
                    
                    Task{
                        do{
                            if try await self.apiUserData.deleteProfilePhoto(pictureId: imageId){
                                DispatchQueue.main.async {
                                    self.usersRealmService.deleteImage(userId: self.keychain.getAcessToken() ?? "", pictureId: imageId)
                                    self.imageService.deleteImage(by: imageId)
                                    self.view?.deletePhotoSuccess()
                                }
                            }
                        }catch{
                            
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
