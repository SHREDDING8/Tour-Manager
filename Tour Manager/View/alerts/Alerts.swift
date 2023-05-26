//
//  Alerts.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.05.2023.
//

import Foundation
import UIKit

enum errorAlertsApi{
    typealias RawValue = (String,String)
    
    case userNotFound
    case unknown
    case invalidEmailOrPassword
    
    var rawValue:RawValue{
        switch self{
        case .unknown:
            return ("Неизвестная ошибка", "Возможна проблема с сервером, повторите попытку позже")
            
        case .userNotFound:
            return ("Ошибка","Такого пользователя не существует")
            
        case .invalidEmailOrPassword:
            return ("Неверный логин или пароль","Проверьте правильность введенных данных и повторите попытку")
        }
        
        
    }
}

enum errorAlertsFront{
    typealias RawValue = (String,String)
    
    case email
    case password
    
    
    
    case textFieldIsEmpty
    
    
    
    var rawValue:RawValue{
        switch self{
        case .email:
            return ("Неправильный Email", "Проверьте правильность введенных данных и повторите попытку")
        case .password:
            return ("Неправильный пароль", "Проверьте правильность введенных данных и повторите попытку")
            
        
            
        case .textFieldIsEmpty:
            return ("Ошибка", "Некоторые текстовые поля пустые")

        }
    }
}

class Alert{
    
    public func errorAlert(errorTypeApi:errorAlertsApi) -> UIAlertController{
        let alert = UIAlertController(title: errorTypeApi.rawValue.0, message: errorTypeApi.rawValue.1, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        return alert
    }
    
    public func errorAlert(errorTypeFront:errorAlertsFront) -> UIAlertController{
        let alert = UIAlertController(title: errorTypeFront.rawValue.0, message: errorTypeFront.rawValue.1, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        return alert
    }
    
}
