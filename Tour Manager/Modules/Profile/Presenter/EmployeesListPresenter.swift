//
//  employeesListPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation

protocol EmployeesListViewProtocol:AnyObject{
    
}

protocol EmployeesListPresenterProtocol:AnyObject{
    init(view:EmployeesListViewProtocol)
}

class EmployeesListPresenter:EmployeesListPresenterProtocol{
    weak var view:EmployeesListViewProtocol?
    
    let apiCompany = ApiManagerCompany()
    let keychain = KeychainService()
    
    required init(view:EmployeesListViewProtocol) {
        self.view = view
    }
    
    
    public func getCompanyUsers(completion: @escaping (Bool, [User]? , customErrorCompany?) ->Void){
        
        self.apiCompany.getCompanyUsers(token: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "") { isGetted, users, error in
            
            if error != nil{
                completion(false, nil, error)
            }
            if isGetted{
                var emloyees:[User] = []
                
                for userApi in users ?? [] {
                    let date = Date.birthdayFromString(dateString: userApi.birthdayDate)
                    
                    
                    let user = User(localId: userApi.uid, email: userApi.email, firstName: userApi.firstName, secondName: userApi.lastName, birthday: date, phone: userApi.phone, companyId: userApi.companyID, accessLevel: userApi.accessLevels)
                    
                    emloyees.append(user)
                }
                
                completion(true, emloyees, nil)
            }

        }
    }
    
    
}
