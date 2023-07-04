//
//  UserDefaults.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.06.2023.
//

import Foundation
import NotificationCenter

class WorkWithUserDefaults{
    private let userDefaults = UserDefaults.standard
    
    public enum userDefaultsKeys:String{
        case token = "token"
        case localId = "localId"
        case refreshToken = "refreshToken"
        case lastRefreshToken = "lastRefreshDate"
        
        case deviceToken = "deviceToken"
    }
    
    init(){
        
    }
    
    public func getAuthToken()->String?{
        let tokenKey:userDefaultsKeys = .token
        let token = self.userDefaults.string(forKey: tokenKey.rawValue)
        
        return token
    }
    
    public func setAuthToken(token:String){
        let tokenKey:userDefaultsKeys = .token
        userDefaults.set(token, forKey: tokenKey.rawValue)
        AppDelegate.user?.setToken(token: token)
    }
    
    
    
    public func getRefreshToken()->String?{
        let refreshTokenKey:userDefaultsKeys = .refreshToken
        let token = self.userDefaults.string(forKey: refreshTokenKey.rawValue)
        
        return token
    }
    
    public func getLocalId()->String{
        let localIdKey:userDefaultsKeys = .localId
        let localId = self.userDefaults.string(forKey: localIdKey.rawValue) ?? ""
        return localId
    }
    
    public func setLoginData(token:String, localId:String, refreshToken:String){
        
        let authTokenKey:userDefaultsKeys = .token
        let localIdKey:userDefaultsKeys = .localId
        let refreshTokenKey:userDefaultsKeys = .refreshToken
        
        self.userDefaults.set(token, forKey:  authTokenKey.rawValue)
        self.userDefaults.set(localId, forKey: localIdKey.rawValue)
        self.userDefaults.set(refreshToken, forKey: refreshTokenKey.rawValue)
        self.setLastRefreshDate(date: Date.now)
    }
    
    
    public func removeLoginData(){
        let authTokenKey:userDefaultsKeys = .token
        let localIdKey:userDefaultsKeys = .localId
        let refreshTokenKey:userDefaultsKeys = .refreshToken
        let lastRefreshTokenKey:userDefaultsKeys = .lastRefreshToken
        
        userDefaults.set(nil, forKey: authTokenKey.rawValue)
        userDefaults.set(nil, forKey: localIdKey.rawValue)
        userDefaults.set(nil, forKey: refreshTokenKey.rawValue)
        userDefaults.set(nil, forKey: lastRefreshTokenKey.rawValue)
    }
    
    public func setLastRefreshDate(date:Date){
        let lastRefreshDateKey:userDefaultsKeys = .lastRefreshToken
        userDefaults.setValue(date, forKey: lastRefreshDateKey.rawValue)
    }
    
    public func isAuthToken(date:Date)->Bool{
        let lastRefreshDateKey:userDefaultsKeys = .lastRefreshToken
        if let lastRefreshDate = userDefaults.object(forKey: lastRefreshDateKey.rawValue) as? Date{
            
            let tokenExpired = Calendar.current.date(byAdding: .minute, value: 55, to: lastRefreshDate)!
            
            print("Current date: \(date)\t TokenExpired: \(tokenExpired)")
            if date > tokenExpired{
                print("isAuthToken false")
                return false
            }
            print("isAuthToken true")
            return true
        }
        print("isAuthToken false not lastRefreshDate ")
        return false
    }
    
    public func getDeviceToken()->String{
        let deviceTokenKey:userDefaultsKeys = .deviceToken
        
        let deviceToken = self.userDefaults.string(forKey: deviceTokenKey.rawValue) ?? ""
        
        return deviceToken
    }
    
    public func setDeviceToken(token:String){
        let deviceTokenKey:userDefaultsKeys = .deviceToken
        
        self.userDefaults.set(token, forKey: deviceTokenKey.rawValue)
    }
    
    
    
}
