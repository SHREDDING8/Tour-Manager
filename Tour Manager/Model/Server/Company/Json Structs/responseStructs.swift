//
//  responseStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation

public struct ResponseAddCompanyJsonStruct:Codable{
    let company_id:String
    let message:String
}

public struct ResponseAddEmployeeToCompanyJsonStruct:Codable{
    let company_name:String
    let message:String
}
