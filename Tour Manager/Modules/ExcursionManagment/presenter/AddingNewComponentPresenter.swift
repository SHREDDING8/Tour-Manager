//
//  AddingNewComponentPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation
import RealmSwift

enum TypeOfNewComponent{
    case route
    case customerCompanyName
    case customerGuiedName
    case excursionPaymentMethod
    
    case guides
    
}

protocol AddingNewComponentViewProtocol:AnyObject{
    func configureRouteView()
    func configureCustomerCompanyNameView()
    func configureCustomerGuiedNameView()
    func configureExcursionPaymentMethodView()
    
    func updateTableView()
    func setTextField(text:String)
    func closePage()
}

protocol AddingNewComponentPresenterProtocol:AnyObject{
    init(view:AddingNewComponentViewProtocol, type:AutofillType, baseValue:String?)
    
    var presentedValues:[AutofillRealmModel] { get }
    var selectedValue:String { get set }
        
    func getCompanyGuides(completion: @escaping (Bool, [User]? , customErrorCompany?) ->Void)
    
    func willAppear()
    func didSelect(index:Int)
    func deleteAt(index:Int)
    func textFieldChanged(text:String)
    func willDissapear()
}

class AddingNewComponentPresenter:AddingNewComponentPresenterProtocol{
    
    weak var view:AddingNewComponentViewProtocol?
    
    var type:AutofillType
    
    var allValues:Results<AutofillRealmModel>!
    var presentedValues:[AutofillRealmModel] = []
    var selectedValue:String = ""
    
    var autoFillRealmService:AutoFillRealmServiceProtocol = AutoFillRealmService()
    
    var apiCompany = ApiManagerCompany()
    var keychain = KeychainService()
    
        
    required init(view:AddingNewComponentViewProtocol, type:AutofillType, baseValue:String?) {
        self.view = view
        self.type = type
        if baseValue != nil{
            self.selectedValue = baseValue ?? ""
            view.setTextField(text: baseValue ?? "")
        }
    }
    
    func willAppear(){
        switch type {
        case .route:
            view?.configureRouteView()
        case .customerCompanyName:
            view?.configureCustomerCompanyNameView()
        case .customerGuiedName:
            view?.configureCustomerGuiedNameView()
        case .excursionPaymentMethod:
            view?.configureExcursionPaymentMethodView()
        }
        allValues = autoFillRealmService.getAllValues(type: type)
        presentedValues = allValues.toArray()
        view?.updateTableView()
    }
    
    func didSelect(index:Int){
        selectedValue = presentedValues[index].value
        view?.setTextField(text: selectedValue)
        view?.closePage()
    }
    
    func deleteAt(index:Int){
        let object = presentedValues[index]
        autoFillRealmService.delete(object: object)
        self.willAppear()
        view?.updateTableView()
    }
    
    func textFieldChanged(text:String){
        self.selectedValue = text
        if text.isEmpty{
            self.presentedValues = self.allValues.toArray()
        }else{
            self.presentedValues = []
            
            for value in allValues{
                if value.value.lowercased().contains(text.lowercased()){
                    presentedValues.append(value)
                }
            }
        }
        
        view?.updateTableView()
    }
    
    func willDissapear(){
        if !selectedValue.isEmpty{
            self.autoFillRealmService.saveValue(type: type, value: selectedValue)
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
