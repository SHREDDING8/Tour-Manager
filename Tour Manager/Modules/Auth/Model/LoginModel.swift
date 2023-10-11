//
//  LoginModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.10.2023.
//

import Foundation

struct loginData{
    var email:String = ""
    var firstPassword = ""
    var secondPassword = ""
    
    mutating func clear(){
        email = ""
        firstPassword = ""
        secondPassword = ""
    }
    mutating func clearPasswords(){
        firstPassword = ""
        secondPassword = ""
    }
}
