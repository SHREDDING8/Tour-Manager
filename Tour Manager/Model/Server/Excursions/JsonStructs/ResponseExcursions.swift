//
//  ResponseExcursions.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation

// MARK: - WelcomeElement
struct ResponseGetExcursion: Codable {
    let tourId:String
    
    let tourName:String
    let tourRoute:String
    let tourNotes:String
    let tourNumberOfPeople:Int
    let tourTimeStart:String
    let customerCompanyName:String
    let customerGuideName:String
    let customerGuideContact:String
    
    let isPaid:Bool
    let paymentMethod:String
    let paymentAmount:Int

    enum CodingKeys: String, CodingKey {
        case tourId = "tour_id"
        
        case tourName = "tour_name"
        case tourRoute = "tour_route"
        case tourNotes = "tour_notes"
        case tourNumberOfPeople = "tour_number_of_people"
        case tourTimeStart = "tour_time_start"
        case customerCompanyName = "customer_company_name"
        case customerGuideName = "customer_guide_name"
        case customerGuideContact = "customer_guide_contact"
        
        case isPaid = "is_paid"
        case paymentMethod = "payment_method"
        case paymentAmount = "payment_amount"
    }
}

struct ResponseUpdateExcursion:Codable{
    let message:String
    let tour_id:String
}


