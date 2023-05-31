//
//  sendStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation

struct SendAddCompanyJsonStruct:Codable{
    let token:String
    let company_name:String
}

struct SendAddEmployeeToCompanyJsonStruct:Codable{
    let token:String
    let company_id:String
}

struct SendCompanyInfoJsonStruct:Codable{
    let token:String
    let company_id:String
    let company_name:String
    
}
