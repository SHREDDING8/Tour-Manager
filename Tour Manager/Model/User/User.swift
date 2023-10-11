//
//  User.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import UIKit

public struct UserDataServerStruct:Codable{
    var token:String
    let email:String
    let first_name:String
    let last_name:String
    let birthday_date:String
    let phone:String
    
}


class User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.getLocalID() == rhs.getLocalID()
    }
    
    
    internal let apiAuth = ApiManagerAuth()
    
    internal let apiUserData = ApiManagerUserData()
    
    internal let apiCompany = ApiManagerCompany()

    enum AccessLevelEnum:String{
        
        case isOwner = ""
        
        case readGeneralCompanyInformation = "read_general_company_information"
        case writeGeneralCompanyInformation = "write_general_company_information"
        case readLocalIdCompany = "read_local_id_company"
        case readCompanyEmployee = "read_company_employee"
        
        case canChangeAccessLevel = "can_change_access_level"
        case canWriteTourList = "can_write_tour_list"
        case canReadTourList = "can_read_tour_list"
        
        case isGuide = "is_guide"
        
        
        init?(index:Int) {
            switch index{
            case 0: self = .isOwner
            case 1: self = .readGeneralCompanyInformation
            case 2: self = .writeGeneralCompanyInformation
            case 3: self = .readLocalIdCompany
            case 4: self = .readCompanyEmployee
            case 5: self = .canChangeAccessLevel
            case 6: self = .canReadTourList
            case 7: self = .canWriteTourList
            case 8: self = .isGuide
            default:
                return nil
            }
        }
    }
    
    
    internal var token:String?
    internal var refreshToken:String?
    internal var deviceToken:String?
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
        .canChangeAccessLevel: false,
        .canReadTourList: false,
        .canWriteTourList:false,
        .isGuide:false
        
    ]
    
    
    // MARK: - Inits
    init(){
        self.token = ""
    }
    
    
    init(localId: String, firstName: String?, secondName: String?, email:String?, phone:String?, birthdayDate:Date) {
        self.localId = localId
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.phone = phone
        self.birthday = birthdayDate
    }
    init(localId: String, email: String, firstName: String, secondName: String, birthday: Date, phone: String, companyId:String, accessLevel:AccessLevels){
        self.localId = localId
        self.email = email
        self.firstName = firstName
        self.secondName = secondName
        self.birthday = birthday
        self.phone = phone
//        self.company.setLocalIDCompany(localIdCompany: companyId)
        
        self.accessLevel[.readGeneralCompanyInformation] = accessLevel.readGeneralCompanyInformation
        self.accessLevel[.writeGeneralCompanyInformation] = accessLevel.writeGeneralCompanyInformation
        self.accessLevel[.readLocalIdCompany] = accessLevel.readLocalIDCompany
        self.accessLevel[.readCompanyEmployee] = accessLevel.readCompanyEmployee
        self.accessLevel[.canChangeAccessLevel] = accessLevel.canChangeAccessLevel
        self.accessLevel[.isOwner] = accessLevel.isOwner
        
        self.accessLevel[.canReadTourList] = accessLevel.canReadTourList
        self.accessLevel[.canWriteTourList] = accessLevel.canWriteTourList
        self.accessLevel[.isGuide] = accessLevel.isGuide
        
        
    }
    
    // MARK: - Token
    public func setToken(token:String){
        self.token = token
    }
    
    public func getToken()->String{
        return self.token ?? ""
    }
    
    // MARK: - Refresh Token
    public func setRefreshToken(refreshToken:String){
        self.refreshToken = refreshToken
    }
    
    public func getRefreshToken()->String{
        return self.refreshToken ?? ""
    }
    
    // MARK: - Device Token
    public func setDeviceToken(deviceToken:String){
        self.deviceToken = refreshToken
    }
    
    public func getDeviceToken()->String{
        return self.deviceToken ?? ""
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
