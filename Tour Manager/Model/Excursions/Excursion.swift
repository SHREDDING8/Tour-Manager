//
//  Excursion.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import Foundation

enum Status:String{
    case waiting = "waiting"
    case cancel = "cancel"
    case accepted = "accept"
}

public struct SelfGuide {
    var guideInfo:User
    var isMain:Bool
    var status:Status = .waiting
}

public class Excursion{
    // MARK: - Fields
    
    var localId:String?
    
    var excursionName:String = ""
    
    var route:String = ""
    
    var additionalInfromation:String = ""
    
    var dateAndTime:Date = Date.now
    
    var numberOfPeople:Int = 0
    

    var customerCompanyName:String = ""
    
    var customerGuideName:String = ""
    
    var companyGuidePhone:String = ""
    var paymentMethod = ""
    
    var paymentAmount:Int = 0
    
    var isPaid:Bool = false
    
    var selfGuides:[SelfGuide] = []
    
    
    init(localId: String, excursionName:String, route:String, additionalInfromation:String, numberOfPeople:Int, dateAndTime:Date,customerCompanyName:String, customerGuideName:String, companyGuidePhone:String, isPaid:Bool, paymentMethod:String, paymentAmount:Int) {
        self.localId = localId
        self.excursionName = excursionName
        self.route = route
        self.additionalInfromation = additionalInfromation
        self.numberOfPeople = numberOfPeople
        self.dateAndTime = dateAndTime
        self.customerCompanyName = customerCompanyName
        self.customerGuideName = customerGuideName
        self.companyGuidePhone = companyGuidePhone
        self.isPaid = isPaid
        self.paymentMethod = paymentMethod
        self.paymentAmount = paymentAmount
    }
    
    init(localId: String? = nil, companyName: String? = nil, numberOfPeople: Int? = nil, companyGuideName: String? = nil, companyGuidePhone: String? = nil, paymentAmount: Int? = nil, isPaid: Bool? = nil, selfGuides: [SelfGuide]? = nil, route: String? = nil, dateAndTime:Date? = nil) {
        self.localId = localId ?? ""
        self.customerCompanyName = companyName ?? ""
        self.numberOfPeople = numberOfPeople ?? 0
        self.customerGuideName = companyGuideName ?? ""
        self.companyGuidePhone = companyGuidePhone ?? ""
        self.paymentAmount = paymentAmount ?? 0
        self.isPaid = isPaid ?? false
        self.selfGuides = selfGuides ?? []
        self.route = route ?? ""
        self.dateAndTime = dateAndTime ?? Date.now
    }
    
    init() {
        
    }
}
