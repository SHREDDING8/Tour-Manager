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

public struct ResponseAccessLevel:Codable{
    
    let read_general_company_information:Bool
    let write_general_company_information:Bool
    let read_local_id_company:Bool
    let read_company_employee:Bool
    let can_change_access_level:Bool
}
