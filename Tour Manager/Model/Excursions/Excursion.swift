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

public class Excursion:Equatable{
    
    
    // MARK: - Fields
    
    var localId:String = ""
    
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
    
    public static func == (lhs: Excursion, rhs: Excursion) -> Bool {
        
//        print(lhs.localId == rhs.localId)
//        print(lhs.excursionName == rhs.excursionName)
//        print(lhs.route == rhs.route)
//        print(lhs.additionalInfromation == rhs.additionalInfromation)
//        print(lhs.guideAccessNotes == rhs.guideAccessNotes)
//        print(lhs.dateAndTime == rhs.dateAndTime)
//        print(lhs.numberOfPeople == rhs.numberOfPeople)
//        print(lhs.customerCompanyName == rhs.customerCompanyName)
//        print(lhs.customerGuideName == rhs.customerGuideName)
//        print(lhs.companyGuidePhone == rhs.companyGuidePhone)
//        print(lhs.paymentMethod == rhs.paymentMethod)
//        print(lhs.paymentAmount == rhs.paymentAmount)
//        print(lhs.isPaid == rhs.isPaid)
//        print(lhs.selfGuides == rhs.selfGuides)
        
        let first = lhs.localId == rhs.localId &&
        lhs.excursionName == rhs.excursionName &&
        lhs.route == rhs.route &&
        lhs.additionalInfromation == rhs.additionalInfromation &&
        lhs.guideAccessNotes == rhs.guideAccessNotes &&
        lhs.dateAndTime == rhs.dateAndTime &&
        lhs.numberOfPeople == rhs.numberOfPeople &&
        lhs.customerCompanyName == rhs.customerCompanyName &&
        lhs.customerGuideName == rhs.customerGuideName &&
        lhs.companyGuidePhone == rhs.companyGuidePhone &&
        lhs.paymentMethod == rhs.paymentMethod &&
        lhs.paymentAmount == rhs.paymentAmount &&
        lhs.isPaid == rhs.isPaid &&
        lhs.selfGuides.count == rhs.selfGuides.count
        
        if first{
            for guide in 0..<lhs.selfGuides.count{
                if !(lhs.selfGuides[guide].guideInfo == rhs.selfGuides[guide].guideInfo){
                    return false
                }
            }
            return true
        }
        
        return false
    }
    
    
    
    
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
    
    public func copy()->Excursion{
        let tour = Excursion(localId: self.localId, excursionName: self.excursionName, route: self.route, additionalInfromation: self.additionalInfromation, guideAccessNotes: self.guideAccessNotes, numberOfPeople: self.numberOfPeople, dateAndTime: self.dateAndTime, customerCompanyName: self.customerCompanyName, customerGuideName: self.customerGuideName, companyGuidePhone: self.companyGuidePhone, isPaid: self.isPaid, paymentMethod: self.paymentMethod, paymentAmount: self.paymentAmount)
        
        tour.selfGuides = self.selfGuides
        
        return tour
    }
    
    init() {
        
    }
}
