//
//  ToursGeneralModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 27.11.2023.
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

struct ExcrusionModel:Equatable{
    
    enum GuideStatus:String{
        case waiting = "waiting"
        case cancel = "cancel"
        case accept = "accept"
        
        func getColor() ->UIColor{
            switch self {
            case .waiting:
                return .systemYellow
            case .cancel:
                return .systemRed
            case .accept:
                return .systemGreen
            }
        }
    }
    
    struct Guide:Equatable{
        static func == (lhs: ExcrusionModel.Guide, rhs: ExcrusionModel.Guide) -> Bool {
            lhs.id == rhs.id &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.isMain == rhs.isMain &&
            lhs.status == rhs.status
        }
        
        var id:String
        var firstName:String
        var lastName:String
        var isMain:Bool = false
        var status: GuideStatus = .waiting
        
        var images:[(id:String, image:UIImage)] = []
    }
        
    var tourId:String = ""
    var tourTitle:String = ""
    var route:String = ""
    var notes:String = ""
    var guideCanSeeNotes:Bool = false
    
    var dateAndTime:Date = Date.now
    
    var numberOfPeople:String = "0"
    

    var customerCompanyName:String = ""
    
    var customerGuideName:String = ""
    
    var companyGuidePhone:String = ""
    var paymentMethod = ""
    
    var paymentAmount:String = "0"
    
    var isPaid:Bool = false
    
    var guides:[Guide]
    
    static func == (lhs: ExcrusionModel, rhs: ExcrusionModel) -> Bool {
        return lhs.tourTitle == rhs.tourTitle &&
        lhs.route == rhs.route &&
        lhs.notes == rhs.notes &&
        lhs.guideCanSeeNotes == rhs.guideCanSeeNotes &&
        lhs.dateAndTime == rhs.dateAndTime ||
        lhs.numberOfPeople == rhs.numberOfPeople ||
        lhs.customerCompanyName == rhs.customerCompanyName &&
        lhs.customerGuideName == rhs.customerGuideName &&
        lhs.companyGuidePhone == rhs.companyGuidePhone &&
        lhs.paymentMethod == rhs.paymentMethod &&
        lhs.paymentAmount == rhs.paymentAmount &&
        lhs.isPaid == rhs.isPaid &&
        lhs.guides == rhs.guides
    }
}
