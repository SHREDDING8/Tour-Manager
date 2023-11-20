//
//  ExtendedSettingsPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import Foundation

protocol ExtendedSettingsViewProtocol:AnyObject{
    func updateLoggedDevices(devices:[DevicesModel])
    
    func logoutAllSuccessful()
    func logoutAllError()
    
}

protocol ExtendedSettingsPresenterProtocol:AnyObject{
    init(view:ExtendedSettingsViewProtocol)
    
    func revokeAllDevices()
    func deleteAccount()
    func deleteCompany()
    func isOwner()->Bool
    
    func getFullName()->String
    func getCompanyName()->String
    
    func loadLoggedDevices()
    func getLoggedDevicesFromServer()
}
class ExtendedSettingsPresenter:ExtendedSettingsPresenterProtocol{
    weak var view:ExtendedSettingsViewProtocol?
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    
    let authNetworkService:ApiManagerAuthProtocol = ApiManagerAuth()
    
    let devicesRealmService:DevicesRealmServiceProtocol = DevicesRealmService()
    
    required init(view:ExtendedSettingsViewProtocol) {
        self.view = view
    }
    
    func revokeAllDevices(){
        Task{
            do{
                if try await self.authNetworkService.logoutAllDevices(){
                    DispatchQueue.main.async {
                        self.view?.logoutAllSuccessful()
                    }
                }
                
            }catch{
                DispatchQueue.main.async {
                    self.view?.logoutAllError()
                }
            }
        }
    }
    
    func deleteAccount(){
        
    }
    
    func deleteCompany(){
        
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
                
            }catch{
                
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
