//
//  ExcrusionModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 14.10.2023.
//

import Foundation
import UIKit

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
        var id:String
        var firstName:String
        var lastName:String
        var isMain:Bool = false
        var status: GuideStatus = .waiting
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
