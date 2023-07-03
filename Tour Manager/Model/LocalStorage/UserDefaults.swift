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
    
    public enum LoginUserDefaultsKeys:String{
        case token = "token"
        case localId = "localId"
        case refreshToken = "refreshToken"
    }
    
    init(){
        
    }
    
    public func getAuthToken()->String?{
        let tokenKey:LoginUserDefaultsKeys = .token
        let token = self.userDefaults.string(forKey: tokenKey.rawValue)
        
        return token
    }
    public func setAuthToken(token:String){
        let tokenKey:LoginUserDefaultsKeys = .token
        userDefaults.set(token, forKey: tokenKey.rawValue)
        AppDelegate.user?.setToken(token: token)
    }
    
    public func getRefreshToken()->String?{
        let refreshTokenKey:LoginUserDefaultsKeys = .refreshToken
        let token = self.userDefaults.string(forKey: refreshTokenKey.rawValue)
        
        return token
    }
    
    public func removeLoginData(){
        userDefaults.set(nil, forKey: "authToken")
        userDefaults.set(nil, forKey: "localId")
        userDefaults.set(nil, forKey: "refreshToken")
    }
    
    public func setLastRefreshDate(date:Date){
        userDefaults.setValue(date, forKey: "lastRefreshDate")
    }
    
    public func isAuthToken(date:Date)->Bool{
        if let lastRefreshDate = userDefaults.object(forKey: "lastRefreshDate") as? Date{
            
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
    
    public func incrementBadge(on:Int){
        let currentBadge = userDefaults.integer(forKey: "badgeNumber")
        
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(currentBadge + on)
        } else {

            UIApplication.shared.applicationIconBadgeNumber = currentBadge + on
        }
        userDefaults.setValue(currentBadge + on, forKey: "badgeNumber")
    }
    
    public func removeBadge(){
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {

            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        userDefaults.setValue(0, forKey: "badgeNumber")
    }
    
    
}
