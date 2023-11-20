//
//  DeviceRealmModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.11.2023.
//

import Foundation
import RealmSwift

final class DeviceRealmModel:Object{
    
    enum DeviceTypeRealm:String,PersistableEnum{
        case apple
        case telegram
    }
    
    @Persisted var name:String
    @Persisted var type:DeviceTypeRealm
    
    convenience init(name: String, type: DeviceTypeRealm) {
        self.init()
        self.name = name
        self.type = type
    }
}
