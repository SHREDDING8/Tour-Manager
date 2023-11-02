//
//  ExcursionRealmModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 16.10.2023.
//

import Foundation
import RealmSwift


class DatesExcursion:Object{
    @Persisted(primaryKey: true) var dateString:String
    @Persisted var tours:List<ExcursionRealmModel>
    
    convenience init(dateString: String, tours: List<ExcursionRealmModel>) {
        self.init()
        self.dateString = dateString
        self.tours = tours
    }
    
    func getTours() -> [ExcursionRealmModel]{
        return tours.sorted { first, second in
            first.dateAndTime < second.dateAndTime
        }
    }
}

class ExcursionRealmModel:Object{
    @Persisted(primaryKey: true) var tourId:String
    @Persisted var tourTitle:String
    @Persisted var route:String = ""
    @Persisted var notes:String = ""
    @Persisted var guideCanSeeNotes:Bool = false
    
    @Persisted var dateAndTime:Date = Date.now
    
    @Persisted var numberOfPeople:String = "0"
    

    @Persisted var customerCompanyName:String = ""
    
    @Persisted var customerGuideName:String = ""
    
    @Persisted var companyGuidePhone:String = ""
    @Persisted var paymentMethod = ""
    
    @Persisted var paymentAmount:String = "0"
    
    @Persisted var isPaid:Bool = false
    
    @Persisted var guides:List<OneGuideRealmModel>
    
    convenience init(tourId: String, tourTitle: String, route: String, notes: String, guideCanSeeNotes: Bool, dateAndTime: Date, numberOfPeople: String, customerCompanyName: String, customerGuideName: String, companyGuidePhone: String, paymentMethod: String = "", paymentAmount: String, isPaid: Bool, guides: List<OneGuideRealmModel>) {
        self.init()
        self.tourId = tourId
        self.tourTitle = tourTitle
        self.route = route
        self.notes = notes
        self.guideCanSeeNotes = guideCanSeeNotes
        self.dateAndTime = dateAndTime
        self.numberOfPeople = numberOfPeople
        self.customerCompanyName = customerCompanyName
        self.customerGuideName = customerGuideName
        self.companyGuidePhone = companyGuidePhone
        self.paymentMethod = paymentMethod
        self.paymentAmount = paymentAmount
        self.isPaid = isPaid
        self.guides = guides
    }
}

class OneGuideRealmModel:Object{
    
    enum GuideStatus:String, PersistableEnum{
        case waiting = "waiting"
        case cancel = "cancel"
        case accept = "accept"
    }
    
    @Persisted var id:String
    @Persisted var firstName:String
    @Persisted var lastName:String
    @Persisted var isMain:Bool
    @Persisted var status: GuideStatus
    
    convenience init(id: String, firstName: String, lastName: String, image: Data? = nil, isMain: Bool, status: GuideStatus) {
        self.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isMain = isMain
        self.status = status
    }
}
