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
    
    public var excursions:[Excursion] = []{
        didSet{
            excursions = excursions.sorted(by: { $0.dateAndTime < $1.dateAndTime })
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
    
        
    public func setGuideTourStatus(token: String, uid: String, companyId: String, tourDate: String, tourId: String, guideStatus: Status, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        apiManagerExcursions.setGuideTourStatus(token: token, uid: uid, companyId: companyId, tourDate: tourDate, tourId: tourId, guideStatus: guideStatus) { isSetted, error in
            completion(isSetted,error)
        }
    }
    
    
}
