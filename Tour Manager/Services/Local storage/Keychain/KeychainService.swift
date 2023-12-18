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
    
    func getRefreshToken()->String?
    func setRefreshToken(token:String)
    
    func getDeviceToken()->String?
    func setDeviceToken(token:String)
    
    
    func getLocalId()->String?
    func setLocalId(id:String)
    
    func setCompanyLocalId(companyLocalId:String)
    func setCompanyName(companyName:String)
    
    func getCompanyLocalId()->String?
    func getCompanyName()->String?
    
    
    func removeAllData()
    
}

final class KeychainService:KeychainServiceProtocol{

    let keychain = KeychainSwift()
    
    private enum TokensKeys{
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let lastRefreshToken = "lastRefreshDate"
        static let deviceToken = "deviceToken"
        
        
    }
    private enum UserDataKeys{
        static let localId = "localId"
        
        static let companyLocalId = "companyLocalId"
        static let companyName = "companyName"
    }
        
    let dateFormatter = DateFormatter()
    let dateFormat = "MM-dd-yyyy HH:mm"
    
    init(){
        dateFormatter.dateFormat = dateFormat
        keychain.accessGroup = ProcessInfo.processInfo.environment["KEYCHAIN_GROUP"]!
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
            
            return tokenExpired > Date.now
            
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
    

    func setCompanyLocalId(companyLocalId:String){
        keychain.set(companyLocalId, forKey: UserDataKeys.companyLocalId)
    }
    func setCompanyName(companyName:String){
        keychain.set(companyName, forKey: UserDataKeys.companyName)
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
