//
//  User.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import UIKit


protocol UserProtocol{

        
    func setToken(token:String)
    func getToken() -> String
    
    func setLocalID(localId:String)
    func getLocalID()->String?
    
    func setDataAuth(token:String,localId:String)
    
    
    func getPersonalData() -> User.UserDataServerStruct
}

class User:UserProtocol{
    
    private let convertDate = ConvertDate()
    
    
    struct UserDataServerStruct:Codable{
        let token:String
        let email:String
        let first_name:String
        let last_name:String
        let birthday_date:String
        let phone:String
        
    }
    
    enum accessLevelEnum{
        case readGeneralCompanyInformation
        case writeGeneralCompanyInformation
    }
    
    
    
    private var token:String?
    private var localId:String?
    private var email:String?
    
    private var firstName:String?
    private var secondName:String?
    private var birthday:Date?
    private var phone:String?
    
    private var localIdCompany:String?
    private var nameCompany:String?
    
    private var accessLevel:[accessLevelEnum:Bool] = [
        .readGeneralCompanyInformation: false,
        .writeGeneralCompanyInformation: false
    ]
    
    
    // MARK: - Inits
    init(){
        self.token = ""
        self.localId = ""
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
    // MARK: - birthday
    
    public func setBirthday(birthday:Date){
        self.birthday = birthday
    }
    public func getBirthday() -> Date{
        return self.birthday ?? Date.now
    }
    public func getBirthday() -> String{
        return convertDate.birthdayToString(date: self.birthday ?? Date.now)
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
    
    
    // MARK: - Personal Data
    public func getPersonalData() -> UserDataServerStruct{
        let date = convertDate.birthdayToString(date: self.getBirthday())
        
        let res = UserDataServerStruct(token: self.token ?? "", email: self.email! , first_name: self.firstName!, last_name: self.secondName!, birthday_date: date, phone: self.phone!)
        
        return res
    }
    
    
    public func printData(){
        print("localId: \(localId ?? "" )")
        print("email: \(email ?? "")")
        print("firstName: \(firstName ?? "")")
        print("secondName: \(secondName ?? "")")
        print("birthday: \(convertDate.birthdayToString(date:birthday!))")
        print("phone: \(phone ?? "")")
        print("localIdCompany: \(localIdCompany ?? "")")
        print("nameCompany: \(nameCompany ?? "")")
        
    }
}
