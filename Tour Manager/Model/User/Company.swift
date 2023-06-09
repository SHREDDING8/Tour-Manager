//
//  Company.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import Foundation

class Company{
    
    private var localIdCompany:String?
    private var nameCompany:String?
    
    private let apiCompany = ApiManagerCompany()
    
    private var isPrivate = false
    
    private var emloyee:[User] = []
    
    
    
    // MARK: - localIdCompany
    
    public func setLocalIDCompany(localIdCompany:String){
        self.localIdCompany = localIdCompany
    }
    
    public func getLocalIDCompany()->String{
        return self.localIdCompany ?? ""
    }
    
    // MARK: - nameCompany
    
    public func setNameCompany(nameCompany:String){
        self.nameCompany = nameCompany
    }
    
    public func getNameCompany()->String{
        return self.nameCompany ?? ""
    }
    
    // MARK: - IsPrivate
    
    public func setIsPrivate(isPrivate:Bool){
        self.isPrivate = isPrivate
    }
    
    public func getIsPrivate()->Bool{
        return self.isPrivate
    }
    
    
    public func setCompanyNameApi(token:String, completion: @escaping (Bool, customErrorCompany?) -> Void){
        
        self.apiCompany.addCompany(token: token, companyName: self.getNameCompany()) { isSetted, response, error  in
            if error != nil{
                completion(false,error)
            }
            if isSetted{
                self.setLocalIDCompany(localIdCompany: response?.company_id ?? "")
                completion(true,nil)
            }
        }
    }
    
    public func addEmployeeToCompany(token:String, completion: @escaping (Bool, customErrorCompany?) -> Void){
        self.apiCompany.addEmployeeToCompany(token: token, companyId: self.getLocalIDCompany()) { isAdded, response, error in
            if error != nil{
                completion(false,error)
            }
            if isAdded{
                self.setNameCompany(nameCompany: response?.company_name ?? "")
                completion(true,nil)
            }
        }
    }
    
    public func updateCompanyInfo(token:String, companyName:String, completion: @escaping (Bool, customErrorCompany?) ->Void){
        self.apiCompany.updateCompanyInfo(token: token, companyId: self.getLocalIDCompany(), companyName: companyName) { isUpdated, error in
            if error != nil{
                completion(false,error)
            }
            
            if isUpdated{
                self.setNameCompany(nameCompany: companyName)
                completion(true, nil)
            }
        }
    }
    
    public func DeleteCompany(token:String, completion: @escaping (Bool, customErrorCompany?) ->Void){
        self.apiCompany.DeleteCompany(token: token, companyId: self.getLocalIDCompany()) { isDeleted, error in
            completion(isDeleted,error)
        }
    }
    
    public func getCompanyUsers(token:String, completion: @escaping (Bool, [User]? , customErrorCompany?) ->Void){
        
        self.apiCompany.getCompanyUsers(token: token, companyId: self.getLocalIDCompany()) { isGetted, users, error in
            
            if error != nil{
                completion(false, nil, error)
            }
            if isGetted{
                self.emloyee = []
                
                for userApi in users ?? [] {
                    let date = Date.birthdayFromString(dateString: userApi.birthdayDate)
                    
                    
                    let user = User(localId: userApi.uid, email: userApi.email, firstName: userApi.firstName, secondName: userApi.lastName, birthday: date, phone: userApi.phone, companyId: userApi.companyID, accessLevel: userApi.accessLevels)
                    
                    self.emloyee.append(user)
                }
                
                completion(true, self.emloyee, nil)
            }

        }
    }
    
    
    public func getCompanyGuides(token:String, completion: @escaping (Bool, [User]? , customErrorCompany?) ->Void){
        
        self.apiCompany.getCompanyGuides(token: token, companyId: self.getLocalIDCompany()) { isGetted, users, error in
            
            if error != nil{
                completion(false, nil, error)
            }
            if isGetted{
                self.emloyee = []
                
                for userApi in users ?? [] {
                    let date = Date.birthdayFromString(dateString: userApi.birthdayDate)
                    
                    
                    let user = User(localId: userApi.uid, email: userApi.email, firstName: userApi.firstName, secondName: userApi.lastName, birthday: date, phone: userApi.phone, companyId: userApi.companyID, accessLevel: userApi.accessLevels)
                    
                    self.emloyee.append(user)
                }
                
                completion(true, self.emloyee, nil)
            }

        }
    }
    
    
    
}
