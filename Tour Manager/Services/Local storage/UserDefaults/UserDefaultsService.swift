//
//  UserDefaultsService.swift
//  Tour Manager
//
//  Created by SHREDDING on 02.11.2023.
//

import Foundation

protocol UserDefaultsServiceProtocol{
    func isFirstLaunch()->Bool
}

final class UserDefaultsService:UserDefaultsServiceProtocol{
    enum Keys{
        static let isFirstLaunch = "isFirstLaunch"
    }
    
    let userDefaults = UserDefaults.standard
    
    func isFirstLaunch() -> Bool{
        if let _ = userDefaults.object(forKey: Keys.isFirstLaunch){
            return false
        }
        
        userDefaults.set(true, forKey: Keys.isFirstLaunch)
        
        return true
    }
}
