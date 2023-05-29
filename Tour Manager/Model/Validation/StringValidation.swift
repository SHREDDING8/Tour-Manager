//
//  StringValidation.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import Foundation


class StringValidation{
    
    
    public func validatePasswordsString(_ firstPasswordString:String, _ secondPasswordString:String) -> Bool{
        if firstPasswordString.count < 8{
            return false
        }
        return firstPasswordString == secondPasswordString
    }
    
    public func validateIsEmptyString(_ strings:[String])->Bool{
        for string in strings {
            if string.trimmingCharacters(in: CharacterSet(charactersIn: " ")).isEmpty{
                return true
            }
        }
        
        return false
    }
    
    
    func validatePhone(value: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: value)
    }
    
}
