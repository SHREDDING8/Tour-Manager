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
}

struct ResponseIsUserExistsJsonStruct: Codable {
    let userExists:Bool
}
