//
//  StringValidation.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import Foundation


final class StringValidation{
    
    public func validateEmail(_ email:String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
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
    
    func validateLenghtString(string:String, min:Int = 0, max:Int)->Bool{
        if string.count >= min && string.count <= max{
            return true
        }
        return false
    }
    
    func validateNumberWithPlus(value:String)->Bool{
        let regex = "^[0-9]+(\\+[0-9]+)*$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: value)
    }
    
}
