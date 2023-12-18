//
//  DevicesRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.11.2023.
//

import Foundation
import RealmSwift

protocol DevicesRealmServiceProtocol{
    func getAllDevices() -> [DevicesModel]
    func deleteAll()
    func addDevice(device:DeviceRealmModel)
}

final class DevicesRealmService:DevicesRealmServiceProtocol{
    let realm = try! Realm()
    
    func getAllDevices() -> [DevicesModel]{
        var result:[DevicesModel] = []
        let devicesRealm = realm.objects(DeviceRealmModel.self)
        
        for device in devicesRealm{
            var type:DevicesModel.DeviceType
            switch device.type{
            case .apple:
                type = .apple
            case .telegram:
                type = .telegram
            }
            
            result.append(
                DevicesModel(
                    type: type,
                    name: device.name
                )
            )
        }
        
        return result
    }
    
    func deleteAll(){
        try! realm.write {
            let devicesRealm = realm.objects(DeviceRealmModel.self)
            realm.delete(devicesRealm)
        }
    }
    
    func addDevice(device:DeviceRealmModel){
        try! realm.write({
            realm.add(device)
        })
    }
}
