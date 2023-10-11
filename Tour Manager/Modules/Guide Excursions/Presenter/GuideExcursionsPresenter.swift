//
//  GuideExcursionsPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation

protocol ExcursionsGuideCalendarViewProtocol:AnyObject{
    
}

protocol ExcursionsGuideCalendarPresenterProtocol:AnyObject{
    init(view:ExcursionsGuideCalendarViewProtocol)
    
    var excursions:[Excursion] { get set }
    
    func getExcursionsListForGuideByRange(startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListForGuideByRange?, customErrorExcursion?)->Void )
    
    func getExcursionsForGuidesFromApi(date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void)
}

class ExcursionsGuideCalendarPresenter:ExcursionsGuideCalendarPresenterProtocol{
    weak var view:ExcursionsGuideCalendarViewProtocol?
    
    var excursions:[Excursion] = []
    
    let keychain = KeychainService()
    let apiManagerExcursions = ApiManagerExcursions()
    
    required init(view:ExcursionsGuideCalendarViewProtocol) {
        self.view = view
    }
    
    public func getExcursionsListForGuideByRange(startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListForGuideByRange?, customErrorExcursion?)->Void ){
        apiManagerExcursions.getExcursionsForGuideListByRange(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", startDate: startDate, endDate: endDate) { isGetted, list, error in
            completion(isGetted,list,error)
        }
    }
    
    public func getExcursionsForGuidesFromApi(date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void){
        
        self.excursions = []
        var newTours:[Excursion] = []
        
        apiManagerExcursions.GetExcursionsForGuides(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", date: date.birthdayToString()) { isGetted, excursionsfromApi, error in
            
            if isGetted{
                for excursion in excursionsfromApi!{
                    
                    let newExcursion = Excursion(localId: excursion.tourId, excursionName: excursion.tourName, route: excursion.tourRoute, additionalInfromation: excursion.tourNotes, guideAccessNotes: excursion.tourNotesVisible, numberOfPeople: excursion.tourNumberOfPeople, dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: excursion.tourTimeStart), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, companyGuidePhone: excursion.customerGuideContact,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount)
                    
                    for guide in excursion.tourGuides{
                        let newGuideInfo = User(localId: guide.guideID, firstName: guide.guideFirstName, secondName: guide.guideLastName,email: guide.guideEmail,phone: guide.guidePhone, birthdayDate: Date.dateStringToDate(dateString: guide.birthdayDate))
                        let newGuide = SelfGuide(guideInfo: newGuideInfo, isMain: guide.isMain, status: .init(rawValue: guide.status) ?? .waiting)
                        
                        newExcursion.selfGuides.append(newGuide)
                    }
                    
                    newTours.append(newExcursion)
                }
                self.excursions = newTours
                completion(true, nil)
                
            }
            
            if let err = error{
                completion(false, err)
            }
            
            
        }
    }
}
