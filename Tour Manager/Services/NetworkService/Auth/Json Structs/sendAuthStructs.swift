//
//  sendAuthStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import Foundation

// MARK: - sendLogInJsonStruct
struct SendLogInJsonStruct: Codable {
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
    let password:String
    let newPassword:String
    
    let apnsToken: ApnsToken
    
    enum CodingKeys: String, CodingKey {
        case apnsToken = "apns_token"
        case password
        case email
        case newPassword = "new_password"
    }
}

struct logOutAll: Codable {
    let apnsToken: ApnsToken
    let password: String

    enum CodingKeys: String, CodingKey {
        case apnsToken = "apns_token"
        case password
    }
}


struct sendLogOut:Codable{
    let apns_vendor_id:String
}
