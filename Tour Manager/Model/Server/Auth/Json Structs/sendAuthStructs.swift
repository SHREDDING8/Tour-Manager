//
//  sendAuthStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import Foundation

struct sendLogInJsonStruct: Codable {
    let email:String
    let password:String
}

struct sendResetPassword: Codable{
    let email:String
}
