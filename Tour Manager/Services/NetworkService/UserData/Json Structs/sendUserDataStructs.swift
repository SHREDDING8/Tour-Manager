//
//  sendUserDataStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import Foundation

struct SendGetUserInfoJsonStruct: Codable{
    let token:String
}

public struct UserDataServerStruct:Codable{
    var token:String
    let email:String
    let first_name:String
    let last_name:String
    let birthday_date:String
    let phone:String
    
}
