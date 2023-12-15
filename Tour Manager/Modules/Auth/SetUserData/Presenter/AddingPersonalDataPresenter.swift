//
//  AddingPersonalDataPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation

protocol AddingPersonalDataViewProtocol:AnyObject, BaseViewControllerProtocol{
    func successful()
    func validationError(msg:String)
}

protocol AddingPersonalDataPresenterProtocol:AnyObject{
    init(view:AddingPersonalDataViewProtocol, typeOfAccount: AddingPersonalDataPresenter.TypeOfAccount)
    
    var type:AddingPersonalDataPresenter.TypeOfAccount { get }
    var model:SetInfoModel { get set }
    
    func buttonTapped()
}
class AddingPersonalDataPresenter:AddingPersonalDataPresenterProtocol{
    weak var view:AddingPersonalDataViewProtocol?
    
    enum TypeOfAccount{
        case newCompany
        case newEmployee
    }
    var type:TypeOfAccount
    
    let validationStrings = StringValidation()
    
    let keychainService = KeychainService()
    
    let apiUserData = ApiManagerUserData()
    let apiCompany = ApiManagerCompany()
    let employeeNetworkservice:EmployeeNetworkServiceProtocol = EmployeeNetworkService()
    
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    
    var model:SetInfoModel = SetInfoModel()
    
    required init(view:AddingPersonalDataViewProtocol, typeOfAccount: AddingPersonalDataPresenter.TypeOfAccount) {
        self.view = view
        self.type = typeOfAccount
    }
    
    func buttonTapped(){
        if validationStrings.validateIsEmptyString([model.company, model.birthday, model.firstName, model.phone, model.secondName]){
            view?.validationError(msg: "Некоторые поля пустые")
            return
        }
        
        let json = SetUserInfoSend(
            first_name: model.firstName,
            last_name: model.secondName,
            birthday_date: model.birthday,
            phone: model.phone
        )
        view?.showLoadingView()
        view?.setLoading()
        Task{
            do{
                try await apiUserData.setUserInfo(info:json)
                
                switch self.type {
                case .newCompany:
                    try await self.apiCompany.addCompany(companyName: model.company)
                    
                case .newEmployee:
                    try await employeeNetworkservice.addEmployeeToCompany(companyId: model.company)
                }
                
                let userDataResult = try await self.apiUserData.getUserInfo()
                
                DispatchQueue.main.async {
                    
                    let me = UserRealm(localId: self.keychainService.getLocalId()!, firstName: userDataResult.first_name, secondName: userDataResult.last_name, email: userDataResult.email, phone: userDataResult.phone, birthday: Date.dateStringToDate(dateString: userDataResult.birthday_date), imageIDs: userDataResult.profile_pictures)
                    
                    self.usersRealmService.setUserInfo(user: me)
                    
                    self.keychainService.setCompanyLocalId(companyLocalId: userDataResult.company_id)
                    self.keychainService.setCompanyName(companyName: userDataResult.company_name)
                    
                    self.view?.successful()
                }
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    view?.showError(error: err)
                }
                
            }
            
            DispatchQueue.main.async {
                self.view?.stopLoadingView()
                self.view?.stopLoading()
            }
            
        }
    }
    
}
