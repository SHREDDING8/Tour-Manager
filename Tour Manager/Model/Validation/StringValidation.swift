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
}
