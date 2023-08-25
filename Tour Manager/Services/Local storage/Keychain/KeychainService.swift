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
    
    
    func getLocalId()->String?
    func setLocalId(id:String)
    
    
    func removeAllData()
    
}

class KeychainService:KeychainServiceProtocol{

    let keychain = KeychainSwift()
    
    private enum TokensKeys{
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let lastRefreshToken = "lastRefreshDate"
        
        
    }
    private enum UserDataKeys{
        static let localId = "localId"
        
        static let deviceToken = "deviceToken"
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
    
    public func getLocalId()->String?{
        return keychain.get(UserDataKeys.localId)
    }
    public func setLocalId(id:String){
        keychain.set(id, forKey: UserDataKeys.localId)
    }
    
    func removeAllData(){
        for key in keychain.allKeys{
            keychain.delete(key)
        }
    }
    
}
