//
//  ExcursionsControllerModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation


class ExcursionsControllerModel{
    
    let apiManagerExcursions = ApiManagerExcursions()
    let apiManagerAutofill = ApiManagerAutoFill()
    
    public var excursions:[Excursion] = []
    
    
    
    public func getExcursionsFromApi(token:String, companyId:String, date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        self.excursions = []
        
        apiManagerExcursions.GetExcursions(token: token, companyId: companyId, date: date.birthdayToString()) { isGetted, excursionsfromApi, error in
            
            if isGetted{
                for excursion in excursionsfromApi!{
                    
                    let newExcursion = Excursion(localId: excursion.tourId, excursionName: excursion.tourName, route: excursion.tourRoute, additionalInfromation: excursion.tourNotes, numberOfPeople: excursion.tourNumberOfPeople, dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: excursion.tourTimeStart), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, companyGuidePhone: excursion.customerGuideContact,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount)
                    
                    for guide in excursion.tourGuides{
                        let newGuideInfo = User(localId: guide.guideID, firstName: guide.guideFirstName, secondName: guide.guideLastName,email: guide.guideEmail)
                        let newGuide = SelfGuide(guideInfo: newGuideInfo, isMain: guide.isMain, status: .init(rawValue: guide.status) ?? .waiting)
                        
                        newExcursion.selfGuides.append(newGuide)
                    }
                    
                    self.excursions.append(newExcursion)
                }
                
                completion(true, nil)
                
            }
            
            
        }
    }
    
    
    public func getExcursionsForGuidesFromApi(token:String, companyId:String, date:Date, completion: @escaping (Bool, customErrorExcursion?)->Void){
        
        self.excursions = []
        
        apiManagerExcursions.GetExcursionsForGuides(token: token, companyId: companyId, date: date.birthdayToString()) { isGetted, excursionsfromApi, error in
            
            if isGetted{
                for excursion in excursionsfromApi!{
                    
                    let newExcursion = Excursion(localId: excursion.tourId, excursionName: excursion.tourName, route: excursion.tourRoute, additionalInfromation: excursion.tourNotes, numberOfPeople: excursion.tourNumberOfPeople, dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: excursion.tourTimeStart), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, companyGuidePhone: excursion.customerGuideContact,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount)
                    
                    for guide in excursion.tourGuides{
                        let newGuideInfo = User(localId: guide.guideID, firstName: guide.guideFirstName, secondName: guide.guideLastName,email: guide.guideEmail)
                        let newGuide = SelfGuide(guideInfo: newGuideInfo, isMain: guide.isMain, status: .init(rawValue: guide.status) ?? .waiting)
                        
                        newExcursion.selfGuides.append(newGuide)
                    }
                    
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
    
    public func deleteExcursion(token: String, companyId: String, excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void){
        apiManagerExcursions.deleteExcursion(token: token, companyId: companyId, date: excursion.dateAndTime.birthdayToString(), excursionId: excursion.localId ?? "") { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func getAutofill(token: String, companyId: String, autofillKey:AutofillKeys,completion: @escaping (Bool, [String]?,  customErrorAutofill?)->Void){
        apiManagerAutofill.getAutofill(token: token, companyId: companyId, autoFillKey: autofillKey) { isGetted, values, error in
            completion(isGetted,values,error)
        }
    }
    
    public func addAutofill(token: String, companyId: String, autofillKey:AutofillKeys,autofillValue:String, completion: @escaping (Bool, customErrorAutofill?)->Void){
        apiManagerAutofill.addAutofill(token: token, companyId: companyId, autoFillKey: autofillKey, autofillValue: autofillValue) { isAdded, error in
            completion(isAdded,error)
        }
    }
    
    public func deleteAutofill(token: String, companyId: String, autofillKey:AutofillKeys,autofillValue:String, completion: @escaping (Bool, customErrorAutofill?)->Void){
        apiManagerAutofill.deleteAutofill(token: token, companyId: companyId, autoFillKey: autofillKey, autofillValue: autofillValue) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
}
