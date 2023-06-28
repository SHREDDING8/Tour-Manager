//
//  Excursion.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import Foundation
import UIKit

enum Status:String{
    case waiting = "waiting"
    case cancel = "cancel"
    case accepted = "accept"
    case emptyGuides = "emptyGuides"
    
    public func getColor()->UIColor{
        switch self{
            
        case .waiting:
            return .systemYellow
        case .cancel:
            return .systemRed
        case .accepted:
            return .systemGreen
        case .emptyGuides:
            return .systemBlue
        }
    }
}

public struct SelfGuide:Equatable {
        
    var guideInfo:User
    var isMain:Bool
    var status:Status = .waiting
    
    var statusColor:UIColor{
        switch status {
        case .waiting:
            return .systemYellow
        case .cancel:
            return .systemRed
        case .accepted:
            return .systemGreen
        case .emptyGuides:
            return .systemBlue
        }
    }
}

public class Excursion{
    // MARK: - Fields
    
    var localId:String?
    
    var excursionName:String = ""
    
    var route:String = ""
    
    var additionalInfromation:String = ""
    
    var guideAccessNotes = false
    
    var dateAndTime:Date = Date.now
    
    var numberOfPeople:String = "0"
    

    var customerCompanyName:String = ""
    
    var customerGuideName:String = ""
    
    var companyGuidePhone:String = ""
    var paymentMethod = ""
    
    var paymentAmount:String = "0"
    
    var isPaid:Bool = false
    
    var selfGuides:[SelfGuide] = []
    
    
    init(localId: String, excursionName:String, route:String, additionalInfromation:String,
         guideAccessNotes:Bool, numberOfPeople:String, dateAndTime:Date,customerCompanyName:String, customerGuideName:String, companyGuidePhone:String, isPaid:Bool, paymentMethod:String, paymentAmount:String) {
        self.localId = localId
        self.excursionName = excursionName
        self.route = route
        self.additionalInfromation = additionalInfromation
        self.guideAccessNotes = guideAccessNotes
        self.numberOfPeople = numberOfPeople
        self.dateAndTime = dateAndTime
        self.customerCompanyName = customerCompanyName
        self.customerGuideName = customerGuideName
        self.companyGuidePhone = companyGuidePhone
        self.isPaid = isPaid
        self.paymentMethod = paymentMethod
        self.paymentAmount = paymentAmount
    }
    
    init(localId: String? = nil, companyName: String? = nil, numberOfPeople: String? = nil, companyGuideName: String? = nil, companyGuidePhone: String? = nil, paymentAmount: String? = nil, isPaid: Bool? = nil, selfGuides: [SelfGuide]? = nil, route: String? = nil, dateAndTime:Date? = nil) {
        self.localId = localId ?? ""
        self.customerCompanyName = companyName ?? ""
        self.numberOfPeople = numberOfPeople ?? "0"
        self.customerGuideName = companyGuideName ?? ""
        self.companyGuidePhone = companyGuidePhone ?? ""
        self.paymentAmount = paymentAmount ?? "0"
        self.isPaid = isPaid ?? false
        self.selfGuides = selfGuides ?? []
        self.route = route ?? ""
        self.dateAndTime = dateAndTime ?? Date.now
    }
    
    init() {
        
    }
}
