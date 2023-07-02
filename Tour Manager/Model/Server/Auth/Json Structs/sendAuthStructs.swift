//
//  sendAuthStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import Foundation

// MARK: - sendLogInJsonStruct
struct sendLogInJsonStruct: Codable {
    let email, password: String
    let apnsToken: ApnsToken

    enum CodingKeys: String, CodingKey {
        case email, password
        case apnsToken = "apns_token"
    }
}

// MARK: - ApnsToken
struct ApnsToken: Codable {
    let vendorID, deviceToken, deviceName: String

    enum CodingKeys: String, CodingKey {
        case vendorID = "vendor_id"
        case deviceToken = "device_token"
        case deviceName = "device_name"
    }
}


struct sendResetPassword: Codable{
    let email:String
}
struct sendUpdatePassword:Codable{
    let email:String
    let old_password:String
    let new_password:String
}


struct sendLogOut:Codable{
    let token:String
    let apns_vendor_id:String
}
