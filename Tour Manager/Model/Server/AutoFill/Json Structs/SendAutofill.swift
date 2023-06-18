//
//  SendAutofill.swift
//  Tour Manager
//
//  Created by SHREDDING on 17.06.2023.
//

import Foundation

public enum AutofillKeys:String{
    case excursionRoute = "tour_route"
    case excursionCustomerGuideContact = "tour_customer_guide_contact"
    case excursionCustomerCompanyName = "tour_customer_company_name"
}


struct SendGetAutofill: Codable{
    let token:String
    let company_id:String
    let autofill_key:String
}

struct SendAddAutofill: Codable{
    let token:String
    let company_id:String
    let autofill_key:String
    let autofill_value:String
}
