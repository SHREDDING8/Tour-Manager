//
//  LogInJsonStruct.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import Foundation

struct LogInErrorJsonStruct: Codable {
    let message:String
}


struct LogInJsonStruct: Codable {
    let token:String
    let localId:String
}

