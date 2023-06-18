//
//  ResponseAutoFill.swift
//  Tour Manager
//
//  Created by SHREDDING on 17.06.2023.
//

import Foundation

struct ResponseGetAutofill:Codable{
    let values:[String]
    
    enum CodingKeys:String,CodingKey{
        
        case values = "variants"
    }
}
