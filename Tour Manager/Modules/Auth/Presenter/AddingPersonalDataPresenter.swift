//
//  AddingPersonalDataPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol AddingPersonalDataViewProtocol:AnyObject{
    
}

protocol AddingPersonalDataPresenterProtocol:AnyObject{
    init(view:AddingPersonalDataViewProtocol)
    
    var email:String { get set }
    
    var firstName:String { get set }
    var secondName:String { get set }
    
    var birthday:String { get set }
    
    var phone:String { get set }
    
    var companyLocalId:String { get set }
    
    var companyName:String { get set }
    
    func setUserInfoApi(completion: @escaping (Bool, customErrorUserData?)->Void)
    
    func setCompanyNameApi(completion: @escaping (Bool, customErrorCompany?) -> Void)
    
    func addEmployeeToCompany(completion: @escaping (Bool, customErrorCompany?) -> Void)
}
class AddingPersonalDataPresenter:AddingPersonalDataPresenterProtocol{
    weak var view:AddingPersonalDataViewProtocol?
    
    let keychain = KeychainService()
    let apiUserData = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    
    
    var email = ""
    
    var firstName = ""
    var secondName = ""
    
    var birthday = ""
    
    var phone = ""
    
    var companyLocalId = ""
    
    var companyName = ""
    
    required init(view:AddingPersonalDataViewProtocol) {
        self.view = view
    }
    
    
    // MARK: - setUserInfoApi
    
    public func setUserInfoApi(completion: @escaping (Bool, customErrorUserData?)->Void){
        let data = UserDataServerStruct(
            token: keychain.getAcessToken() ?? "",
            email: self.email ,
            first_name: self.firstName,
            last_name: self.secondName,
            birthday_date: self.birthday,
            phone: self.phone
        )
        
        self.apiUserData.setUserInfo(data: data) { isSetted, error in
            completion(isSetted,error)
        }
    }
    
    
    
    public func setCompanyNameApi(completion: @escaping (Bool, customErrorCompany?) -> Void){
        
        self.apiCompany.addCompany(token: keychain.getAcessToken() ?? "", companyName: self.companyName) { isSetted, response, error  in
            if error != nil{
                completion(false,error)
            }
            if isSetted{
                self.keychain.setCompanyLocalId(companyLocalId: response?.company_id ?? "")
                completion(true,nil)
            }
        }
    }
    
    public func addEmployeeToCompany(completion: @escaping (Bool, customErrorCompany?) -> Void){
        self.apiCompany.addEmployeeToCompany(token: keychain.getAcessToken() ?? "", companyId: self.companyLocalId) { isAdded, response, error in
            if error != nil{
                completion(false,error)
            }
            if isAdded{
                self.keychain.setCompanyName(companyName: response?.company_name ?? "")
                completion(true,nil)
            }
        }
    }
    
}
