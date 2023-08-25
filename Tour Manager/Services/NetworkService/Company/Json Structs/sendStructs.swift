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

public struct SendUpdateUserAccessLevel:Codable{
    var token:String
    let company_id:String
    let target_uid:String
    
    let can_change_access_level:Bool
    let can_read_tour_list:Bool
    let can_write_tour_list:Bool
    let is_guide:Bool
    let read_company_employee:Bool
    let read_general_company_information:Bool
    let read_local_id_company:Bool
    let write_general_company_information:Bool
}
