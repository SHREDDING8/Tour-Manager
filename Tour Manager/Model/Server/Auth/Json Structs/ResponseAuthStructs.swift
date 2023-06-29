//
//  ResponseAuthStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import Foundation


public struct ResponseLogInJsonStruct: Codable {
    let token:String
    let localId:String
    let refreshToken:String
    
    enum CodingKeys:String, CodingKey{
        
        case token
        case localId = "local_id"
        case refreshToken = "refresh_token"
    }
}

struct ResponseIsUserExistsJsonStruct: Codable {
    let userExists:Bool
}

public struct ResponseRefreshToken: Codable {
    let token:String
}
