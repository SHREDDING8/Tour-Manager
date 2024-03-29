//
//  SendExcursions.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation

struct sendForGetExcursion:Codable{
    let token:String
    let company_id:String
    let tour_date:String
}

struct sendForDeleteExcursion:Codable{
    let token:String
    let company_id:String
    let tour_date:String
    let tour_id:String
}

struct SendGuide:Codable{
    let guide_id: String
    let is_main: Bool
    let status: String

}

struct SendAddTour:Codable{
    let tourName:String
    let tourRoute:String
    let tourNotes:String
    let tourNotesVisible:Bool
    let tourNumberOfPeople:String
    let tourTimeStart:String
    let customerCompanyName:String
    let customerGuideName:String
    let customerGuideContact:String
    
    let isPaid:Bool
    let paymentMethod:String
    let paymentAmount:String
    
    let guides: [SendGuide]
    
    enum CodingKeys: String, CodingKey {
        case tourName = "tour_name"
        case tourRoute = "tour_route"
        case tourNotes = "tour_notes"
        case tourNotesVisible = "tour_notes_visible"
        case tourNumberOfPeople = "tour_number_of_people"
        case tourTimeStart = "tour_time_start"
        case customerCompanyName = "customer_company_name"
        case customerGuideName = "customer_guide_name"
        case customerGuideContact = "customer_guide_contact"
        
        case isPaid = "is_paid"
        case paymentMethod = "payment_method"
        case paymentAmount = "payment_amount"
        
        case guides = "tour_guides"
    }
}
struct SendAddNewExcursion:Codable{
    var token:String
    let companyId:String
    
    let tourName:String
    let tourRoute:String
    let tourNotes:String
    let tourNotesVisible:Bool
    let tourNumberOfPeople:String
    let tourTimeStart:String
    let tourDate:String
    let customerCompanyName:String
    let customerGuideName:String
    let customerGuideContact:String
    
    let isPaid:Bool
    let paymentMethod:String
    let paymentAmount:String
    
    let guides: [SendGuide]
    
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case companyId = "company_id"
        
        case tourName = "tour_name"
        case tourRoute = "tour_route"
        case tourNotes = "tour_notes"
        case tourNotesVisible = "tour_notes_visible"
        case tourNumberOfPeople = "tour_number_of_people"
        case tourTimeStart = "tour_time_start"
        case tourDate = "tour_date"
        case customerCompanyName = "customer_company_name"
        case customerGuideName = "customer_guide_name"
        case customerGuideContact = "customer_guide_contact"
        
        case isPaid = "is_paid"
        case paymentMethod = "payment_method"
        case paymentAmount = "payment_amount"
        
        case guides = "tour_guides"
    }

}

struct SendUpdateExcursion:Codable{
    var token:String
    let companyId:String
    let excursionId:String
    
    let tourName:String
    let tourRoute:String
    let tourNotes:String
    let tourNotesVisible:Bool
    let tourNumberOfPeople:String
    let tourTimeStart:String
    let tourDate:String
    let oldDate:String
    let customerCompanyName:String
    let customerGuideName:String
    let customerGuideContact:String
    
    let isPaid:Bool
    let paymentMethod:String
    let paymentAmount:String
    
    let guides:[SendGuide]
    
    
    
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case companyId = "company_id"
        case excursionId = "tour_id"
        
        case tourName = "tour_name"
        case tourRoute = "tour_route"
        case tourNotes = "tour_notes"
        case tourNotesVisible = "tour_notes_visible"
        case tourNumberOfPeople = "tour_number_of_people"
        case tourTimeStart = "tour_time_start"
        case tourDate = "tour_date"
        case oldDate = "old_tour_date"
        case customerCompanyName = "customer_company_name"
        case customerGuideName = "customer_guide_name"
        case customerGuideContact = "customer_guide_contact"
        
        case isPaid = "is_paid"
        case paymentMethod = "payment_method"
        case paymentAmount = "payment_amount"
        
        case guides = "tour_guides"
    }
}

struct SendGetExcursionsListByRange:Codable{
    let token:String
    let company_id:String
    let tour_date_start:String
    let tour_date_end:String
}

struct SendSetGuideStatus:Codable{
    let guide_status:String
}
