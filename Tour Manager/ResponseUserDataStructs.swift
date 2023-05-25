//
//  ResponseUserDataStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation


struct ResponseGetUserInfoJsonStruct: Codable{
    let email:String
    let first_name:String
    let last_name:String
    let birthday_date:String
    let phone:String
}
