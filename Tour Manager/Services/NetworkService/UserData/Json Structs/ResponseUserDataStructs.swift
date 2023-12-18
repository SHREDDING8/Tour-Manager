//
//  ResponseUserDataStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation


public struct ResponseGetUserInfoJsonStruct: Codable{
    let email:String
    let first_name:String
    let last_name:String
    let birthday_date:String
    let phone:String
    
    let company_id:String
    let company_name:String
    
    let private_company:Bool
    
    let profile_pictures:[String]
    
}

struct ResponseUploadPhoto: Codable {
    let pictureID: String

    enum CodingKeys: String, CodingKey {
        case pictureID = "picture_id"
    }
}
