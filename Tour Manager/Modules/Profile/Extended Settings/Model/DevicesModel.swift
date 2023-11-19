//
//  DevicesModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 19.11.2023.
//

import Foundation

struct DevicesModel{
    enum DeviceType{
        case iphone
        case ipad
        case mac
        case telegram
        case unknowm
    }
    
    var type:DeviceType
    var name:String
}
