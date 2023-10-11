//
//  AddingNewComponentPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation
protocol AddingNewComponentViewProtocol:AnyObject{
    
}

protocol AddingNewComponentPresenterProtocol:AnyObject{
    init(view:AddingNewComponentViewProtocol)
    
    func addAutofill(autofillKey:AutofillKeys,autofillValue:String, completion: @escaping (Bool, customErrorAutofill?)->Void)
    
    func getAutofill(autofillKey:AutofillKeys,completion: @escaping (Bool, [String]?,  customErrorAutofill?)->Void)
    
    func deleteAutofill(autofillKey:AutofillKeys,autofillValue:String, completion: @escaping (Bool, customErrorAutofill?)->Void)
    
    func getCompanyGuides(completion: @escaping (Bool, [User]? , customErrorCompany?) ->Void)
}

class AddingNewComponentPresenter:AddingNewComponentPresenterProtocol{
    weak var view:AddingNewComponentViewProtocol?
    
    let keychain = KeychainService()
    let apiManagerAutofill = ApiManagerAutoFill()
    let apiCompany = ApiManagerCompany()
    
    
    required init(view:AddingNewComponentViewProtocol) {
        self.view = view
    }
    
    public func addAutofill(autofillKey:AutofillKeys,autofillValue:String, completion: @escaping (Bool, customErrorAutofill?)->Void){
        apiManagerAutofill.addAutofill(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", autoFillKey: autofillKey, autofillValue: autofillValue) { isAdded, error in
            completion(isAdded,error)
        }
    }
    
    public func getAutofill(autofillKey:AutofillKeys,completion: @escaping (Bool, [String]?,  customErrorAutofill?)->Void){
        apiManagerAutofill.getAutofill(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", autoFillKey: autofillKey) { isGetted, values, error in
            completion(isGetted,values,error)
        }
    }
    
    public func deleteAutofill(autofillKey:AutofillKeys,autofillValue:String, completion: @escaping (Bool, customErrorAutofill?)->Void){
        apiManagerAutofill.deleteAutofill(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", autoFillKey: autofillKey, autofillValue: autofillValue) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func getCompanyGuides(completion: @escaping (Bool, [User]? , customErrorCompany?) ->Void){
        
        self.apiCompany.getCompanyGuides(token: keychain.getAcessToken() ?? "", companyId: self.keychain.getCompanyLocalId() ?? "") { isGetted, users, error in
            
            if error != nil{
                completion(false, nil, error)
            }
            if isGetted{
                var emloyee:[User] = []
                
                for userApi in users ?? [] {
                    let date = Date.birthdayFromString(dateString: userApi.birthdayDate)
                    
                    
                    let user = User(localId: userApi.uid, email: userApi.email, firstName: userApi.firstName, secondName: userApi.lastName, birthday: date, phone: userApi.phone, companyId: userApi.companyID, accessLevel: userApi.accessLevels)
                    
                    emloyee.append(user)
                }
                
                completion(true, emloyee, nil)
            }

        }
    }
}
