//
//  Alerts.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.05.2023.
//

import Foundation
import UIKit

enum errorAlerts{
    typealias RawValue = (String,String)
    
    case email
    case password
    
    case invalidEmailOrPassword
    
    case requestTimedOut
    
    case unknown
    
    case textFieldIsEmpty
    
    case userNotFound
    
    var rawValue:RawValue{
        switch self{
        case .email:
            return ("Неправильный Email", "Проверьте правильность введенных данных и повторите попытку")
        case .password:
            return ("Неправильный пароль", "Проверьте правильность введенных данных и повторите попытку")
            
        case .invalidEmailOrPassword:
            return ("Неверный логин или пароль","Проверьте правильность введенных данных и повторите попытку")
        
        case .requestTimedOut:
            return ("Ошибка соединения с сервером", "Проверьте соединение с интернетом или повторите попытку позже")
        
        case .unknown:
            return ("Неизвестная ошибка", "Проверьте правильность введенных данных или повторите попытку позже")
            
        case .textFieldIsEmpty:
            return ("Ошибка", "Некоторые текстовые поля пустые")
            
        case .userNotFound:
            return ("Ошибка","Такого пользователя не существует")
        }
        
        
    }
    
    
}

class Alert{
    
    public func errorAlert(_ errorType:errorAlerts) -> UIAlertController{
        let alert = UIAlertController(title: errorType.rawValue.0, message: errorType.rawValue.1, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        return alert
    }
}
