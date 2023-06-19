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
    case emailExists
    case weakPassword
    
    var rawValue:RawValue{
        switch self{
        case .unknown:
            return ("Неизвестная ошибка", "Возможна проблема с сервером, повторите попытку позже")
            
        case .userNotFound:
            return ("Ошибка","Такого пользователя не существует")
            
        case .invalidEmailOrPassword:
            return ("Неверный логин или пароль","Проверьте правильность введенных данных и повторите попытку")
        case .emailExists:
            return ("Пользователь уже существует","Введите другой email")
        case .weakPassword:
            return ("Слабый пароль","Введите более сильный пароль")
        }
        
    }
}

enum errorAlertsFront{
    typealias RawValue = (String,String)
    
    case email
    case password
    case phone
    
    case weakPassword
    
    
    
    case textFieldIsEmpty
    
    
    
    var rawValue:RawValue{
        switch self{
        case .email:
            return ("Неправильный Email", "Проверьте правильность введенных данных и повторите попытку")
        case .password:
            return ("Неправильный пароль", "Проверьте правильность введенных данных и повторите попытку")
        case .phone:
            return ("Неправильный формат телефонного номера", "Проверьте правильность введенных данных и повторите попытку")
            
        case .weakPassword:
            return ("Слабый пароль","Введите более надежный пароль")
        
        case .textFieldIsEmpty:
            return ("Ошибка", "Некоторые текстовые поля пустые")

        }
    }
}


class Alert{
    let controllers = Controllers()
    
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
    
    public func invalidToken(view:UIView, message:String?) -> UIAlertController{
        let alert = UIAlertController(title: "Сессия закончилась", message: message, preferredStyle: .alert)

        let actionExit = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            self.controllers.goToLoginPage(view: view)
        }
        
        alert.addAction(actionExit)
        return alert
    }
    
    public func infoAlert(title:String,meesage:String?)->UIAlertController{
        let alert = UIAlertController(title: title, message: meesage, preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        return alert
    }
    
    
    public func warningAlert(title:String, meesage:String?, actionTitle:String, completion: @escaping ()->Void)->UIAlertController{
        let alert = UIAlertController(title: title, message: meesage, preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Отменить", style: .cancel)
        let actionWithCompletion = UIAlertAction(title: actionTitle, style: .destructive) { _ in
            completion()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionWithCompletion)
        return alert
    }
    
}
