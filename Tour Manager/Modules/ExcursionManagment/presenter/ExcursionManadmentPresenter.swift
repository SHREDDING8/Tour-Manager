//
//  ExcursionManadmentPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation

protocol ExcursionManadmentViewProtocol:AnyObject{
    
}

protocol ExcursionManadmentPresenterProtocol:AnyObject{
    init(view:ExcursionManadmentViewProtocol)
    var excursions:[Excursion] { get set }
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    func deleteExcursion(excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void)
    func getExcursionsFromApi(date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void )
    func getExcursionsListByRange(startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListByRange?, customErrorExcursion?)->Void )
}

class ExcursionManadmentPresenter:ExcursionManadmentPresenterProtocol{
    weak var view:ExcursionManadmentViewProtocol?
    
    var excursions:[Excursion] = []
    
    let keychain = KeychainService()
    let usersRealmService = UsersRealmService()
    let apiManagerExcursions = ApiManagerExcursions()
    
    required init(view:ExcursionManadmentViewProtocol) {
        self.view = view
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    public func deleteExcursion(excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void){
        apiManagerExcursions.deleteExcursion(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", date: excursion.dateAndTime.birthdayToString(), excursionId: excursion.localId) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func getExcursionsFromApi(date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        self.excursions = []
        var newTours:[Excursion] = []
        
        apiManagerExcursions.GetExcursions(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", date: date.birthdayToString()) { isGetted, excursionsfromApi, error in
            
            if isGetted{
                for excursion in excursionsfromApi!{
                    
                    let newExcursion = Excursion(localId: excursion.tourId, excursionName: excursion.tourName, route: excursion.tourRoute, additionalInfromation: excursion.tourNotes, guideAccessNotes: excursion.tourNotesVisible, numberOfPeople: excursion.tourNumberOfPeople, dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: excursion.tourTimeStart), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, companyGuidePhone: excursion.customerGuideContact,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount)
                    
                    for guide in excursion.tourGuides{
                        let newGuideInfo = User(localId: guide.guideID, firstName: guide.guideFirstName, secondName: guide.guideLastName,email: guide.guideEmail,phone: guide.guidePhone,birthdayDate: Date.dateStringToDate(dateString: guide.birthdayDate))
                        let newGuide = SelfGuide(guideInfo: newGuideInfo, isMain: guide.isMain, status: .init(rawValue: guide.status) ?? .waiting)
                        
                        newExcursion.selfGuides.append(newGuide)
                    }
                    
                    newTours.append(newExcursion)
                }
                self.excursions = newTours
                completion(true, nil)
                return
                
            }
            
            completion(false,error)
            
        }
    }
    
    public func getExcursionsListByRange(startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListByRange?, customErrorExcursion?)->Void ){
        apiManagerExcursions.getExcursionsListByRange(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", startDate: startDate, endDate: endDate) { isGetted, list, error in
            completion(isGetted,list,error)
        }
    }
    
    
}
