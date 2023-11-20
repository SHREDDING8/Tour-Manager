//
//  DevicesModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import Foundation

struct DevicesModel{
    enum DeviceType{
        case apple
        case telegram
    }
    
    var type:DeviceType
    var name:String
}
