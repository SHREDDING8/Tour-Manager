//
//  Excursion.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import Foundation

struct SelfGuide {
    var fullName:String
    var localId:String
    var isMain:Bool
}

public class Excursion{
    // MARK: - Fields
    
    var excursionName:String?
    
    var localId:String?
    
    var companyName:String?
    var numberOfPeople:Int?
    var lunchPlace:String?
    var companyGuideName:String?
    var companyGuidePhone:String?
    var paymentAmount:Int?
    var isPaid:Bool?
    
    var selfGuides:[SelfGuide]?
    var route:String?
    
    init(localId: String? = nil, companyName: String? = nil, numberOfPeople: Int? = nil, lunchPlace: String? = nil, companyGuideName: String? = nil, companyGuidePhone: String? = nil, paymentAmount: Int? = nil, isPaid: Bool? = nil, selfGuides: [SelfGuide]? = nil, route: String? = nil) {
        self.localId = localId
        self.companyName = companyName
        self.numberOfPeople = numberOfPeople
        self.lunchPlace = lunchPlace
        self.companyGuideName = companyGuideName
        self.companyGuidePhone = companyGuidePhone
        self.paymentAmount = paymentAmount
        self.isPaid = isPaid
        self.selfGuides = selfGuides
        self.route = route
    }
    
    init() {
        
    }
}
