//
//  Excursion.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import Foundation

enum Status{
    case waiting
    case cancel
    case accepted
}

struct SelfGuide {
    var fullName:String
    var localId:String
    var isMain:Bool
    var status:Status = .waiting
}

public class Excursion{
    // MARK: - Fields
    
    var localId:String?
    
    var excursionName:String = ""
    
    var route:String = ""
    var routes:[String] = ["уи-оэз-обз", "оэз-лбз-уи", "шишки-уи-обз-оэз"]
    
    var additionalInfromation:String = ""
    
    var dateAndTime:Date = Date.now
    
    var numberOfPeople:Int = 0
    

    var customerCompanyName:String = ""
    var customerCompanyNames:[String] = ["Семейный чемодан","антон","тест","экскурсии казань"]
    
    var customerGuideName:String = ""
    var customerGuideNames:[String] = ["Василиса","Михаил","Антон","Дарья Ивановна","Дарина Александровна"]
    
    var companyGuidePhone:String = ""
    
    var paymentAmount:Int = 0
    
    var isPaid:Bool = false
    
    var selfGuides:[SelfGuide]?
    
    
    init(localId: String, excursionName:String, route:String, additionalInfromation:String, numberOfPeople:Int, dateAndTime:Date,customerCompanyName:String, customerGuideName:String, companyGuidePhone:String) {
        self.localId = localId
        self.excursionName = excursionName
        self.route = route
        self.additionalInfromation = additionalInfromation
        self.numberOfPeople = numberOfPeople
        self.dateAndTime = dateAndTime
        self.customerCompanyName = customerCompanyName
        self.customerGuideName = customerGuideName
        self.companyGuidePhone = companyGuidePhone
    }
    
    init(localId: String? = nil, companyName: String? = nil, numberOfPeople: Int? = nil, companyGuideName: String? = nil, companyGuidePhone: String? = nil, paymentAmount: Int? = nil, isPaid: Bool? = nil, selfGuides: [SelfGuide]? = nil, route: String? = nil, dateAndTime:Date? = nil) {
        self.localId = localId ?? ""
        self.customerCompanyName = companyName ?? ""
        self.numberOfPeople = numberOfPeople ?? 0
        self.customerGuideName = companyGuideName ?? ""
        self.companyGuidePhone = companyGuidePhone ?? ""
        self.paymentAmount = paymentAmount ?? 0
        self.isPaid = isPaid ?? false
        self.selfGuides = selfGuides
        self.route = route ?? ""
        self.dateAndTime = dateAndTime ?? Date.now
    }
    
    init() {
        
    }
}
