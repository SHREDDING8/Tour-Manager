//
//  ExtendedSettingsPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import Foundation

protocol ExtendedSettingsViewProtocol:AnyObject, BaseViewControllerProtocol{
    func updateLoggedDevices(devices:[DevicesModel])
    func endRefreshing()
    
    func logoutAllSuccessful()
    
    func deleteSuccess()
}

protocol ExtendedSettingsPresenterProtocol:AnyObject{
    init(view:ExtendedSettingsViewProtocol)
    
    func revokeAllDevices(password:String)
    func deleteAccount()
    func deleteCompany()
    func isOwner()->Bool
    
    func getFullName()->String
    func getCompanyName()->String
    
    func loadLoggedDevices()
    func getLoggedDevicesFromServer()
}
final class ExtendedSettingsPresenter:ExtendedSettingsPresenterProtocol{
    weak var view:ExtendedSettingsViewProtocol?
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    let devicesRealmService:DevicesRealmServiceProtocol = DevicesRealmService()
    
    let authNetworkService:ApiManagerAuthProtocol = ApiManagerAuth()
    let usersNetworkService:ApiManagerUserDataProtocol = ApiManagerUserData()
    let companyNetworkService:ApiManagerCompanyProtocol = ApiManagerCompany()
    
    
    
    required init(view:ExtendedSettingsViewProtocol) {
        self.view = view
    }
    
    func revokeAllDevices(password:String){
        view?.setLoading()
        view?.showLoadingView()
        Task{
            do{
                if try await self.authNetworkService.logoutAllDevices(password: password){
                    DispatchQueue.main.async {
                        self.view?.logoutAllSuccessful()
                        self.loadLoggedDevices()
                    }
                }
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    DispatchQueue.main.async {
                        self.view?.showError(error: err)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopLoading()
                self.view?.stopLoadingView()
            }
            
        }
    }
    
    func deleteAccount(){
        view?.setLoading()
        view?.showLoadingView()
        Task{
            do{
                if try await self.usersNetworkService.deleteCurrentUser(){
                    DispatchQueue.main.async {
                        self.view?.deleteSuccess()
                    }
                }
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    DispatchQueue.main.async {
                        self.view?.showError(error: err)
                    }
                }

            }
            
            DispatchQueue.main.async {
                self.view?.stopLoading()
                self.view?.stopLoadingView()
            }
            
            
        }
    }
    
    func deleteCompany(){
        view?.setLoading()
        view?.showLoadingView()
        
        Task{
            do{
                if try await self.companyNetworkService.deleteCompany(){
                    DispatchQueue.main.async {
                        self.view?.deleteSuccess()
                    }
                }
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    DispatchQueue.main.async {
                        self.view?.showError(error: err)
                    }
                }

            }
            
            DispatchQueue.main.async {
                self.view?.stopLoading()
                self.view?.stopLoadingView()
            }
            
        }
    }
    
    func loadLoggedDevices(){
        getLoggedDevicesFromRealm()
        getLoggedDevicesFromServer()
    }
    
    private func getLoggedDevicesFromRealm(){
        DispatchQueue.main.async {
            let devices = self.devicesRealmService.getAllDevices()
            self.view?.updateLoggedDevices(devices: devices)
        }
    }
    
    public func getLoggedDevicesFromServer(){
        view?.setUpdating()
        Task{
            do{
                let devicesResponse = try await authNetworkService.getLoggedDevices()
                
                DispatchQueue.main.async {
                    self.devicesRealmService.deleteAll()
                }
                
                for device in devicesResponse.appleDevices {
                    DispatchQueue.main.async {
                        self.devicesRealmService.addDevice(
                            device: DeviceRealmModel(
                                name: device,
                                type: .apple
                            )
                        )
                    }
                }
                
                for device in devicesResponse.telegramDevices {
                    DispatchQueue.main.async {
                        self.devicesRealmService.addDevice(
                            device: DeviceRealmModel(
                                name: device,
                                type: .telegram
                            )
                        )
                    }
                }
                self.getLoggedDevicesFromRealm()
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    DispatchQueue.main.async {
                        self.view?.showError(error: err)
                    }
                    
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopUpdating()
                self.view?.endRefreshing()
            }
            
        }
    }
    
    func isOwner()->Bool{
        usersRealmService.getUserAccessLevel(localId: keychainService.getLocalId() ?? "", .isOwner)
    }
    
    func getFullName()->String{
        let info = usersRealmService.getUserInfo(localId: keychainService.getLocalId() ?? "")
        
        return (info?.firstName ?? "") + " " + (info?.secondName ?? "")
    }
    func getCompanyName()->String{
        keychainService.getCompanyName() ?? ""
    }
}
