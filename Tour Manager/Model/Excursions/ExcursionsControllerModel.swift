//
//  ExcursionsControllerModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation


class ExcursionsControllerModel{
    
    let apiManagerExcursions = ApiManagerExcursions()
    
    public var excursions:[Excursion] = []
    
    
    
    public func getExcursionsFromApi(token:String, companyId:String, date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        self.excursions = []
        
        apiManagerExcursions.GetExcursions(token: token, companyId: companyId, date: date.birthdayToString()) { isGetted, excursionsfromApi, error in
            
            if isGetted{
                for excursion in excursionsfromApi!{
                    
                    let newExcursion = Excursion(localId: excursion.tourId, excursionName: excursion.tourName, route: excursion.tourRoute, additionalInfromation: excursion.tourNotes, numberOfPeople: excursion.tourNumberOfPeople, dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: excursion.tourTimeStart), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, companyGuidePhone: excursion.customerGuideContact,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount)
                    
                    self.excursions.append(newExcursion)
                }
                
                completion(true, nil)
                
            }
            
            
        }
    }
    
    
    public func createNewExcursion(token: String, companyId: String, excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void){

        apiManagerExcursions.AddNewExcursion(token: token, companyId: companyId,excursion: excursion) { isAdded, error in
            completion(isAdded,error)
        }
        
    }
    
    public func updateExcursion(token: String, companyId: String, excursion:Excursion, oldDate:Date, completion: @escaping (Bool, customErrorExcursion?)->Void){
        
        apiManagerExcursions.updateExcursion(token: token, companyId: companyId, excursion: excursion, oldDate: oldDate) { isUpdated, error in
            completion(isUpdated,error)
        }
    }
}