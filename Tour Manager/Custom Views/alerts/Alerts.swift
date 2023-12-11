//
//  Alerts.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.05.2023.
//

import Foundation
import UIKit

public struct AlertFields{
    var title:String
    var message:String?
}

enum errorAuthApi{
    typealias RawValue = (String,String)
    
    case userNotFound
    case unknown
    case invalidEmailOrPassword
    case passwordsAreNotEqual
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
            
        case .passwordsAreNotEqual:
            return ("Пароли не совпадают", "Проверьте правильность введенных данных и повторите попытку")
        }
        
    }
}


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
        
//    public func errorAlert(_ viewController:UIViewController, errorCompanyApi:customErrorCompany, completion:(()->Void)? = nil ){
//        if errorCompanyApi == .invalidToken || errorCompanyApi == .tokenExpired{
//            self.invalidToken(viewController, message: errorCompanyApi.getValuesForAlert().message)
//            return
//        }
//        
////        if errorCompanyApi == .notConnected{
////            self.controllers.goToNoConnection(view: viewController.view, direction: .fade)
////            return
////        }
//        
//        let alertFields = errorCompanyApi.getValuesForAlert()
//        let alert = UIAlertController(title: alertFields.title, message: alertFields.message, preferredStyle: .alert)
//        
//        let actionOk = UIAlertAction(title: "Ок", style: .default) { _ in
//            completion?()
//        }
//        alert.addAction(actionOk)
//        
//        viewController.present(alert, animated: true)
//    }
    
//    public func errorAlert(_ viewController:UIViewController, errorUserDataApi:customErrorUserData, completion:(()->Void)? = nil ){
//        if errorUserDataApi == .invalidToken || errorUserDataApi == .tokenExpired{
//            self.invalidToken(viewController, message: errorUserDataApi.getValuesForAlert().message)
//            return
//        }
//        
////        if errorUserDataApi == .notConnected{
////            self.controllers.goToNoConnection(view: viewController.view, direction: .fade)
////            return
////        }
//        
//        let alertFields = errorUserDataApi.getValuesForAlert()
//        let alert = UIAlertController(title: alertFields.title, message: alertFields.message, preferredStyle: .alert)
//        
//        let actionOk = UIAlertAction(title: "Ок", style: .default) { _ in
//            completion?()
//        }
//        alert.addAction(actionOk)
//        
//        viewController.present(alert, animated: true)
//    }
    
//    public func errorAlert(_ viewController:UIViewController, errorExcursionsApi:customErrorExcursion, completion:(()->Void)? = nil ){
//        if errorExcursionsApi == .invalidToken || errorExcursionsApi == .tokenExpired{
//            self.invalidToken(viewController, message: errorExcursionsApi.getValuesForAlert().message)
//            return
//        }
////        if errorExcursionsApi ==  .notConnected{
////            self.controllers.goToNoConnection(view: viewController.view, direction: .fade)
////            return
////        }
//        
//        
//        let alertFields = errorExcursionsApi.getValuesForAlert()
//        let alert = UIAlertController(title: alertFields.title, message: alertFields.message, preferredStyle: .alert)
//        
//        let actionOk = UIAlertAction(title: "Ок", style: .default) { _ in
//            completion?()
//        }
//        alert.addAction(actionOk)
//        
//        viewController.present(alert, animated: true)
//    }
    
    
    public func errorAlert(_ viewController:UIViewController, errorAutoFillApi:customErrorAutofill, completion:(()->Void)? = nil ){
        if errorAutoFillApi == .invalidToken || errorAutoFillApi == .tokenExpired{
            self.invalidToken(viewController, message: errorAutoFillApi.getValuesForAlert().message)
            return
        }
        
//        if errorAutoFillApi ==  .notConnected{
//            self.controllers.goToNoConnection(view: viewController.view, direction: .fade)
//            return
//        }
        
        let alertFields = errorAutoFillApi.getValuesForAlert()
        let alert = UIAlertController(title: alertFields.title, message: alertFields.message, preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "Ок", style: .default) { _ in
            completion?()
        }
        alert.addAction(actionOk)
        
        viewController.present(alert, animated: true)
    }
    
    public func errorAlert(_ viewController:UIViewController, errorTypeApi:errorAuthApi){
                
        let alert = UIAlertController(title: errorTypeApi.rawValue.0, message: errorTypeApi.rawValue.1, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        viewController.present(alert, animated: true)
    }
    
    
    public func errorAlert(errorTypeFront:errorAlertsFront) -> UIAlertController{
        let alert = UIAlertController(title: errorTypeFront.rawValue.0, message: errorTypeFront.rawValue.1, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        return alert
    }
    
    public func invalidToken(_ viewController:UIViewController, message:String?) {
        let alert = UIAlertController(title: "Сессия закончилась", message: message, preferredStyle: .alert)

        let actionExit = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            
//            self.user?.logOut(completion: { isLogOut, error in
////                if error == .notConnected{
////                    self.controllers.goToNoConnection(view: viewController.view, direction: .fade)
////                    return
////                }
//                self.controllers.goToLoginPage(view: viewController.view, direction: .toTop)
//            })
           
        }
        
        alert.addAction(actionExit)
        viewController.present(alert, animated: true)
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
    
    public func validationStringError(_ viewController:UIViewController, title:String,message:String? = nil){
        let alert = UIAlertController(title: title, message: message != nil ? message : "Проверьте правильность введеных данных и повторите попытку", preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        viewController.present(alert, animated: true)
    }
    
    
    public func deleteAlert(_ viewController:UIViewController,title:String, buttonTitle:String, completion: @escaping ()->Void){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let deleteButton = UIAlertAction(title: buttonTitle, style: .destructive) { _ in
            completion()
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteButton)
        alert.addAction(cancel)
        
        viewController.present(alert, animated: true)
    }
    
}
