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
    let is_owner:Bool
    
    let can_read_tour_list:Bool
    let can_write_tour_list:Bool
    let is_guide:Bool
}


// MARK: - GetCompanyUsers
public struct GetCompanyUsersElement: Codable {
    let uid, firstName, lastName, email: String
    let phone, birthdayDate, companyID: String
    let profilePictures:[String]
    let accessLevels: AccessLevels

    enum CodingKeys: String, CodingKey {
        case uid
        case firstName = "first_name"
        case lastName = "last_name"
        case email, phone
        case birthdayDate = "birthday_date"
        case companyID = "company_id"
        case profilePictures = "profile_pictures"
        case accessLevels = "access_levels"
    }
}

// MARK: - AccessLevels
struct AccessLevels: Codable {
    let readGeneralCompanyInformation, writeGeneralCompanyInformation, readLocalIDCompany, readCompanyEmployee: Bool
    let canChangeAccessLevel: Bool
    let isOwner:Bool
    
    let canReadTourList:Bool
    let canWriteTourList:Bool
    let isGuide:Bool

    enum CodingKeys: String, CodingKey {
        case readGeneralCompanyInformation = "read_general_company_information"
        case writeGeneralCompanyInformation = "write_general_company_information"
        case readLocalIDCompany = "read_local_id_company"
        case readCompanyEmployee = "read_company_employee"
        case canChangeAccessLevel = "can_change_access_level"
        case isOwner = "is_owner"
        
        case canReadTourList = "can_read_tour_list"
        case canWriteTourList = "can_write_tour_list"
        case isGuide = "is_guide"
    }
}

