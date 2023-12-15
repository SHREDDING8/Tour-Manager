//
//  EmployeeJsonStructs.swift
//  Tour Manager
//
//  Created by SHREDDING on 15.12.2023.
//

import Foundation

struct RegisterToCompanyResponse:Codable{
    let companyName, message: String

    enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case message
    }
}
