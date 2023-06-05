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
    
}



class User:UserProtocol{
    
    internal let apiAuth = ApiManagerAuth()
    
    internal let apiUserData = ApiManagerUserData()
    
    internal let apiCompany = ApiManagerCompany()
    
    internal let company = Company()
    
    
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
    
    
    internal var token:String?
    internal var localId:String?
    internal var email:String?
    
    internal var firstName:String?
    internal var secondName:String?
    internal var birthday:Date?
    internal var phone:String?
    
    
    internal var accessLevel:[AccessLevelEnum:Bool] = [
        
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
}
