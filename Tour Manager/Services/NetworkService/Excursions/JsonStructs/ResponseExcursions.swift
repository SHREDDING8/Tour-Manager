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
    let tourNotesVisible:Bool
    let tourNumberOfPeople:String
    let tourTimeStart:String
    let customerCompanyName:String
    let customerGuideName:String
    let customerGuideContact:String
    
    let isPaid:Bool
    let paymentMethod:String
    let paymentAmount:String
    
    let tourGuides: [TourGuide]
    
    

    enum CodingKeys: String, CodingKey {
        case tourId = "tour_id"
        
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
        
        case tourGuides = "tour_guides"
    }
}

struct ResponseUpdateExcursion:Codable{
    let message:String
    let tour_id:String
}

// MARK: - TourGuide
struct TourGuide: Codable {
    let guideFirstName, guideLastName, guideEmail, guidePhone: String?
    let isMain: Bool
    let status, guideID, birthdayDate: String

    enum CodingKeys: String, CodingKey {
        case guideFirstName = "guide_first_name"
        case guideLastName = "guide_last_name"
        case guideEmail = "guide_email"
        case guidePhone = "guide_phone"
        case isMain = "is_main"
        case status
        case guideID = "guide_id"
        case birthdayDate = "birthday_date"
    }
}


// MARK: - ResponseGetExcursionsListByRange
public struct ResponseGetExcursionsListByRange: Codable {
    let tourDate: String
    let accept, emptyGuide, waiting, cancel: Bool

    enum CodingKeys: String, CodingKey {
        case tourDate = "tour_date"
        case accept
        case emptyGuide = "empty_guide"
        case waiting, cancel
    }
}

 public typealias ExcursionsListByRange = [ResponseGetExcursionsListByRange]

public struct ResponseGetExcursionsForGuideListByRange: Codable {
    let tourDate: String
    let accept, waiting, cancel: Bool

    enum CodingKeys: String, CodingKey {
        case tourDate = "tour_date"
        case accept
        case waiting, cancel
    }
}

 public typealias ExcursionsListForGuideByRange = [ResponseGetExcursionsForGuideListByRange]



