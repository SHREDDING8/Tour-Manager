//
//  sendUserDataStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import Foundation

public struct SetUserInfoSend:Codable{
    let first_name:String
    let last_name:String
    let birthday_date:String
    let phone:String
}
