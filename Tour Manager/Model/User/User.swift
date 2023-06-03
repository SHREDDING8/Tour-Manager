//
//  User.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import UIKit

public struct UserDataServerStruct:Codable{
    let token:String
    let email:String
    let first_name:String
    let last_name:String
    let birthday_date:String
    let phone:String
    
}


protocol UserProtocol{

        
    func setToken(token:String)
    func getToken() -> String
    
    func setLocalID(localId:String)
    func getLocalID()->String?
    
    func setDataAuth(token:String,localId:String)
    
    
    func getPersonalData() -> UserDataServerStruct
}



class User:UserProtocol{
    
    private let apiAuth = ApiManagerAuth()
    
    private let apiUserData = ApiManagerUserData()
    
    private let apiCompany = ApiManagerCompany()
    
    public let company = Company()
    
    

    
    enum AccessLevelEnum:String{
        
        case isOwner = ""
        
        case readGeneralCompanyInformation = "read_general_company_information"
        case writeGeneralCompanyInformation = "write_general_company_information"
        case readLocalIdCompany = "read_local_id_company"
        case readCompanyEmployee = "read_company_employee"
        
        case canChangeAccessLevel = "can_change_access_level"
        
        
        init?(index:Int) {
            switch index{
            case 0: self = .isOwner
            case 1: self = .readGeneralCompanyInformation
            case 2: self = .writeGeneralCompanyInformation
            case 3: self = .readLocalIdCompany
            case 4: self = .readCompanyEmployee
            case 5: self = .canChangeAccessLevel
            default:
                return nil
            }
        }
    }
    
    
    
    
    private var token:String?
    private var localId:String?
    private var email:String?
    
    private var firstName:String?
    private var secondName:String?
    private var birthday:Date?
    private var phone:String?
    
    
    private var accessLevel:[AccessLevelEnum:Bool] = [
        
        .isOwner: false,
        
        .readGeneralCompanyInformation: false,
        .writeGeneralCompanyInformation: false,
        .readLocalIdCompany: false,
        .readCompanyEmployee:false,
        
        .canChangeAccessLevel: true,
        
    ]
    
    
    // MARK: - Inits
    init(){
        self.token = ""
    }
    
    
    
    init(localId: String, email: String, firstName: String, secondName: String, birthday: Date, phone: String, companyId:String, accessLevel:AccessLevels){
        self.localId = localId
        self.email = email
        self.firstName = firstName
        self.secondName = secondName
        self.birthday = birthday
        self.phone = phone
        self.company.setLocalIDCompany(localIdCompany: companyId)
        
        self.accessLevel[.readGeneralCompanyInformation] = accessLevel.readGeneralCompanyInformation
        self.accessLevel[.writeGeneralCompanyInformation] = accessLevel.writeGeneralCompanyInformation
        self.accessLevel[.readLocalIdCompany] = accessLevel.readLocalIDCompany
        self.accessLevel[.readCompanyEmployee] = accessLevel.readCompanyEmployee
        self.accessLevel[.canChangeAccessLevel] = accessLevel.canChangeAccessLevel
        self.accessLevel[.isOwner] = accessLevel.isOwner
        
        
    }
    
    
    init(token: String, localId: String, email: String, firstName: String, secondName: String, birthday: Date, phone: String) {
        self.token = token
        self.localId = localId
        self.email = email
        self.firstName = firstName
        self.secondName = secondName
        self.birthday = birthday
        self.phone = phone
    }
    
    init (token: String, localId: String, email: String){
        self.token = token
        self.localId = localId
        self.email = email
    }
    
    // MARK: - Token
    public func setToken(token:String){
        self.token = token
    }
    
    public func getToken()->String{
        return self.token ?? ""
    }
    
    // MARK: - localId
    
    public func setLocalID(localId:String){
        self.localId = localId
    }
    
    public func getLocalID()->String?{
        return self.localId
    }
    
    
    // MARK: - Email
    
    public func setEmail(email:String){
        self.email = email
    }
    public func getEmail() ->String{
        return self.email ?? ""
    }
    
    // MARK: - firstName
    public func setFirstName(firstName:String){
        self.firstName = firstName
    }
    public func getFirstName() ->String{
        return self.firstName ?? ""
    }
        
    // MARK: - secondName
    public func setSecondName(secondName:String){
        self.secondName = secondName
    }
    public func getSecondName() ->String{
        return self.secondName ?? ""
    }
    
    public func getFullName()->String{
        return "\(self.getFirstName()) \(self.getSecondName())"
    }
    // MARK: - birthday
    
    public func setBirthday(birthday:Date){
        self.birthday = birthday
    }
    public func getBirthday() -> Date{
        return self.birthday ?? Date.now
    }
    public func getBirthday() -> String{
        return (self.birthday ?? Date.now).birthdayToString()
    }
    
    // MARK: - Phone
    public func setPhone(phone:String){
        self.phone = phone
    }
    public func getPhone() ->String{
        return self.phone ?? ""
    }
    
    
    // MARK: - Auth
    
    public func setDataAuth(token:String,localId:String){
        self.token = token
        self.localId = localId
    }
    
    public func logIn(password:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.logIn(email: self.email ?? "", password: password) { isLogin,logInData, error in
            if error != nil {
                completion(false,error)
                return
            }
            if !isLogin || logInData == nil  {
                completion(false,.unknowmError)
                return
            }
                        
            self.setDataAuth(token: logInData!.token, localId: logInData!.localId)
            
            UserDefaults.standard.set(self.getToken(), forKey:  "authToken")
            UserDefaults.standard.set(self.getLocalID(), forKey: "localId")
            
            completion(true,nil)
            
        }
    }
    
    public func signIn(password:String, completion: @escaping (Bool, customErrorAuth?)->Void ){
        
        self.apiAuth.signIn(email: self.email ?? "", password: password) { isSignIn, error in
            // check errors from api
            if error != nil{
                completion(false, error)
            }
            if isSignIn{
                completion(true,nil)
            }
        }
    }
    
    public func resetPassword(completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.resetPassword(email: self.email ?? "") { isSendEmail, error in
            if error != nil{
                completion(false,error)
                return
            }
            completion(true,nil)
        }
    }
    
    public func updatePassword(oldPassword:String, newPassword:String,completion: @escaping (Bool, customErrorAuth?)->Void ){
        self.apiAuth.updatePassword(email: self.getEmail(), oldPassword: oldPassword, newPassword: newPassword) { isUpdated, error in
            if error != nil{
                completion(false,error)
                return
            }
            completion(true,nil)
        }
    }
    
    public func sendVerifyEmail(password:String, completion: @escaping (Bool, customErrorAuth?)->Void){
        self.apiAuth.sendVerifyEmail(email: self.email ?? "", password: password) { isSent, error in
            if error != nil{
                completion(false,error)
            }
            if isSent ?? false{
                completion(true,nil)
            }
        }
    }
    
    public func isUserExists(completion: @escaping (Bool, customErrorAuth?)->Void){
        self.apiAuth.isUserExists(email: self.email ?? "") { isUserExists, error in
            
            if error != nil{
                completion(false,error)
            }
            
            completion(isUserExists ?? false, nil)
        }
    }
    
    
    // MARK: - Personal Data
    
    public func getUserInfoFromApi(completion: @escaping (Bool, customErrorUserData?)->Void){
        self.apiUserData.getUserInfo(token: self.token ?? "" ) { isInfo, response, error in
            
            
            if error != nil{
                completion(false, error)
                return
            }
            
            if response == nil || !isInfo{
                completion(false, .unknowmError)
                return
            }
            
            self.setEmail(email: response!.email)
            self.setFirstName(firstName: response!.first_name)
            self.setSecondName(secondName: response!.last_name)
            self.setPhone(phone: response!.phone)
            self.setBirthday(birthday: Date.birthdayFromString(dateString: response!.birthday_date))
            
            self.company.setLocalIDCompany(localIdCompany: response!.company_id)
            self.company.setNameCompany(nameCompany: response!.company_name)
            
            self.accessLevel[.isOwner] = response!.is_owner
            self.company.setIsPrivate(isPrivate: response!.private_company)
            
            
            completion(true, nil)
            
        }
    }
    
    public func setUserInfoApi(completion: @escaping (Bool, customErrorUserData?)->Void){
        let data = self.getPersonalData()
        
        self.apiUserData.setUserInfo(data: data) { isSetted, error in
            if error != nil{
                completion(false,error)
            }
            if isSetted{
                completion(true,nil)
            }
        }
    }
    
    
    
    
    public func getPersonalData() -> UserDataServerStruct{
        
        let res = UserDataServerStruct(token: self.token ?? "", email: self.email! , first_name: self.firstName!, last_name: self.secondName!, birthday_date: self.getBirthday(), phone: self.phone!)
        
        return res
    }
    
    public func updatePersonalData(updateField: UserDataFields ,value:String, completion:  @escaping (Bool, customErrorUserData? )->Void ){
        self.apiUserData.updateUserInfo(token: self.getToken() , updateField: updateField , value: value) { isSetted, error in
            if error != nil{
                completion(false, error)
            } else{
                switch updateField {
                case .firstName:
                    self.setFirstName(firstName: value)
                case .secondName:
                    self.setSecondName(secondName: value)
                case .birthdayDate:
                    self.setBirthday(birthday: Date.birthdayFromString(dateString: value))
                case .phone:
                    self.setPhone(phone: value)
                }
                completion(true, nil)
            }
        }
    }
    
    public func deleteCurrentUser(completion: @escaping (Bool, customErrorUserData?)->Void){
        self.apiUserData.deleteCurrentUser(token: self.getToken()) { isDeleted, error in
            completion(isDeleted,error)
        }
    }

    
    
    // MARK: - level Access
    public func getAccessLevel(rule:AccessLevelEnum) -> Bool{
        let result = self.accessLevel[rule]
        return result ?? false
    }
    
    public func getNumberOfAccessLevel()->Int{
        
        return self.accessLevel.count
        
    }
    
    public func getAccessLevelRule(index:Int)->AccessLevelEnum{
        return AccessLevelEnum(index: index) ?? .readGeneralCompanyInformation

    }
    
    public func getAccessLevelLabel(rule:AccessLevelEnum)->String{
        switch rule{
            
        case .isOwner:
            return "Владелец компании"
        case .readGeneralCompanyInformation:
            return "Чтение общей информации о компании"
        case .writeGeneralCompanyInformation:
            return "Изменение общей информации о компании"
        case .readLocalIdCompany:
            return "Чтение Id компании"
        case .readCompanyEmployee:
            return "Просмотр работников компании"
        case .canChangeAccessLevel:
            return "Изменение прав доступа работников компании"
        }
    }
    
    
    public func getAccessLevelFromApi(completion: @escaping (Bool, customErrorCompany?)->Void){
        
        self.apiCompany.getCurrentAccessLevel(token: self.getToken(), companyId: self.company.getLocalIDCompany()) { accessLevel, error in
            if error != nil{
                completion(false,error)
            }
            
            if accessLevel != nil{
                self.accessLevel[.readCompanyEmployee] = accessLevel?.read_company_employee
                self.accessLevel[.readLocalIdCompany] = accessLevel?.read_local_id_company
                self.accessLevel[.readGeneralCompanyInformation] = accessLevel?.read_general_company_information
                self.accessLevel[.writeGeneralCompanyInformation] = accessLevel?.write_general_company_information
                self.accessLevel[.canChangeAccessLevel] = accessLevel?.can_change_access_level
                self.accessLevel[.isOwner] = accessLevel?.is_owner
                
                completion(true,nil)
            }
        }
    }
}
