//
//  TextFieldValidation.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.05.2023.
//

import Foundation
import UIKit

class TextFieldValidation{
    
    public func validateEmailTextField(_ emailTextField:UITextField) -> Bool{
        if !emailTextField.hasText{
            return false
        }
        if emailTextField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) == "" || emailTextField.text == nil{
            return false
        }
        
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailTextField.text)
    }
    
    public func validatePasswordsTextField(_ firstPasswordTextField:UITextField, _ secondPasswordTextField:UITextField) -> Bool{
        if !firstPasswordTextField.hasText{
            return false
        }
        if firstPasswordTextField.text!.count < 8{
            return false
        }
        return firstPasswordTextField.text == secondPasswordTextField.text
    }
    
    public func validateEmptyTextFields(_ textFields:[UITextField]) -> Bool{
        
        for textField in textFields{
            if !textField.hasText{
                return false
            }
        }
        
        return true
    }
}
