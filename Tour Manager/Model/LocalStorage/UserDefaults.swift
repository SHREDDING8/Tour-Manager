//
//  UserDefaults.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.06.2023.
//

import Foundation

class WorkWithUserDefaults{
    private let userDefaults = UserDefaults.standard
    
    public enum loginUserDefaultsKeys:String{
        case token = "token"
        case localId = "localId"
    }
    
    init(){
        
    }
    
    public func removeLoginData(){
        userDefaults.set(nil, forKey: "authToken")
        userDefaults.set(nil, forKey: "localId")
    }
    
}
