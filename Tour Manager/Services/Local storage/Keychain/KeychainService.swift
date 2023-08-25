//
//  KeychainService.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation
import KeychainSwift

protocol KeychainServiceProtocol{
    
    func getAcessToken() -> String?
    func setAcessToken(token:String)
    func isAcessTokenAvailable() -> Bool
    func getLastRefreshDate()->Date?
    
    func getRefreshToken()->String?
    func setRefreshToken(token:String)
    
    func getDeviceToken()->String?
    func setDeviceToken(token:String)
    
    
    func getLocalId()->String?
    func setLocalId(id:String)
    
    func setEmail(email:String)
    func setFirstName(firstName:String)
    func setSecondName(secondName:String)
    func setPhone(phone:String)
    func setBirthday(birthday:String)
    func setCompanyLocalId(companyLocalId:String)
    func setCompanyName(companyName:String)
    
    func getEmail()->String?
    func getFirstName()->String?
    func getSecondName()->String?
    func getPhone()->String?
    func getBirthday()->String?
    func getCompanyLocalId()->String?
    func getCompanyName()->String?
    
    
    func removeAllData()
    
}

class KeychainService:KeychainServiceProtocol{

    let keychain = KeychainSwift()
    
    private enum TokensKeys{
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let lastRefreshToken = "lastRefreshDate"
        static let deviceToken = "deviceToken"
        
        
    }
    private enum UserDataKeys{
        static let localId = "localId"
        
        static let email = "email"
        static let firstName = "firstName"
        static let secondName = "secondName"
        static let phone = "phone"
        static let birthday = "birthday"
        static let companyLocalId = "companyLocalId"
        static let companyName = "companyName"
    }
    
    let dateFormatter = DateFormatter()
    let dateFormat = "MM-dd-yyyy HH:mm"
    
    init(){
        dateFormatter.dateFormat = dateFormat
    }
    
    // MARK: - Tokens
    public func getAcessToken() -> String?{
        return keychain.get(TokensKeys.accessToken)
    }
    
    public func setAcessToken(token:String){
        keychain.set(token, forKey: TokensKeys.accessToken)
        keychain.set(dateFormatter.string(from: Date.now), forKey: TokensKeys.lastRefreshToken)
    }
    
    public func getLastRefreshDate()->Date?{
        let dateString = keychain.get(TokensKeys.lastRefreshToken)
        let date = dateFormatter.date(from: dateString ?? "")
        return date
    }
    
    public func getRefreshToken() -> String?{
        return keychain.get(TokensKeys.refreshToken)
    }
    public func setRefreshToken(token:String){
        keychain.set(token, forKey: TokensKeys.refreshToken)
    }
    
    public func isAcessTokenAvailable()->Bool{
        
        if let lastRefreshDate = self.getLastRefreshDate(){
            
            let tokenExpired = Calendar.current.date(byAdding: .minute, value: 55, to: lastRefreshDate)!
            
            return tokenExpired > lastRefreshDate
            
        }
        
        return false
    }
    
    func getDeviceToken()->String?{
        return keychain.get(TokensKeys.deviceToken)
    }
    
    func setDeviceToken(token:String){
        keychain.set(token, forKey: TokensKeys.deviceToken)
    }
    
    // MARK: - User Data
    public func getLocalId()->String?{
        return keychain.get(UserDataKeys.localId)
    }
    public func setLocalId(id:String){
        keychain.set(id, forKey: UserDataKeys.localId)
    }
    
    func setEmail(email:String){
        keychain.set(email, forKey: UserDataKeys.email)
    }
    func setFirstName(firstName:String){
        keychain.set(firstName, forKey: UserDataKeys.firstName)
    }
    func setSecondName(secondName:String){
        keychain.set(secondName, forKey: UserDataKeys.secondName)
    }
    func setPhone(phone:String){
        keychain.set(phone, forKey: UserDataKeys.phone)
    }
    func setBirthday(birthday:String){
        keychain.set(birthday, forKey: UserDataKeys.birthday)
    }
    func setCompanyLocalId(companyLocalId:String){
        keychain.set(companyLocalId, forKey: UserDataKeys.companyLocalId)
    }
    func setCompanyName(companyName:String){
        keychain.set(companyName, forKey: UserDataKeys.companyName)
    }
    
    func getEmail()->String?{
        return keychain.get(UserDataKeys.email)
    }
    func getFirstName()->String?{
        return keychain.get(UserDataKeys.firstName)
    }
    func getSecondName()->String?{
        return keychain.get(UserDataKeys.secondName)
    }
    func getPhone()->String?{
        return keychain.get(UserDataKeys.phone)
    }
    func getBirthday()->String?{
        return keychain.get(UserDataKeys.birthday)
    }
    func getCompanyLocalId()->String?{
        return keychain.get(UserDataKeys.companyLocalId)
    }
    func getCompanyName()->String?{
        return keychain.get(UserDataKeys.companyName)
    }
    
    func removeAllData(){
        for key in keychain.allKeys{
            keychain.delete(key)
        }
    }
    
}
