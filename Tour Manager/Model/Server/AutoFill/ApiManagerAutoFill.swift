//
//  ApiManagerAutoFill.swift
//  Tour Manager
//
//  Created by SHREDDING on 17.06.2023.
//

import Foundation
import Alamofire


public enum customErrorAutofill{
    case tokenExpired
    case invalidToken
    case unknowmError
    case autofillKeyDoesNotExist
    
    case permissionDenied
    case currentUserIsNotInThisCompany
    case companyDoesNotExist
    
    public func getValuesForAlert()->AlertFields{
        switch self {
        case .tokenExpired:
            return  AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .invalidToken:
            return  AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .unknowmError:
            return AlertFields(title: "Произошла неизвестная ошибка на сервере")
        case .autofillKeyDoesNotExist:
            return  AlertFields(title: "Произошла ошибка", message: "Данного значения не существует")
        case .permissionDenied:
            return AlertFields(title: "Произошла ошибка", message: "Недостаточно прав доступа для совершения этого действия")
        case .currentUserIsNotInThisCompany:
            return AlertFields(title: "Произошла ошибка", message: "Пользователь не числится в этой компании")
        case .companyDoesNotExist:
            return AlertFields(title: "Произошла ошибка", message: "Компания является частной или не существует")
        }
    }
    
}
class ApiManagerAutoFill{
    private static let domain = GeneralData.domain
    private static let prefix =  domain + "autofill"
    
    private let routeGetAutofill = prefix + "/get_autofill"
    private let routeAddAutofill = prefix + "/add_autofill"
    private let routeDeleteAutofill = prefix + "/delete_autofill"
    
    
    public func getAutofill(token:String, companyId:String, autoFillKey:AutofillKeys, completion: @escaping (Bool,[String]?,customErrorAutofill?)->Void ){
        
        let url = URL(string: routeGetAutofill)!
        
        let jsonData = SendGetAutofill(token: token, company_id: companyId, autofill_key: autoFillKey.rawValue)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data ?? Data())
                completion(false, nil, error)
                return
            } else if response.response?.statusCode == 200{
                let autofillValues = try! JSONDecoder().decode(ResponseGetAutofill.self, from: response.data!)
                completion(true, autofillValues.values, nil)
            }else{
                completion(false, nil, .unknowmError)
            }
        }
    }
    
    public func addAutofill(token:String, companyId:String, autoFillKey:AutofillKeys, autofillValue:String, completion: @escaping (Bool,customErrorAutofill?)->Void ){
        
        let url = URL(string: routeAddAutofill)!
        
        let jsonData = SendAddAutofill(token: token, company_id: companyId, autofill_key: autoFillKey.rawValue,autofill_value: autofillValue)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data ?? Data())
                completion(false, error)
                return
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            }else{
                completion(false, .unknowmError)
            }
        }
    }
    
    
    public func deleteAutofill(token:String, companyId:String, autoFillKey:AutofillKeys, autofillValue:String, completion: @escaping (Bool,customErrorAutofill?)->Void ){
        
        let url = URL(string: routeDeleteAutofill)!
        
        let jsonData = SendAddAutofill(token: token, company_id: companyId, autofill_key: autoFillKey.rawValue,autofill_value: autofillValue)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = self.checkError(data: response.data ?? Data())
                completion(false, error)
                return
                
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            }else{
                completion(false, .unknowmError)
            }
        }
    }
    
    private func checkError(data:Data)->customErrorAutofill{
        if let error = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: data){
            switch error.message{
            case "Token expired":
                return .tokenExpired
            case "Invalid Firebase ID token":
                return .invalidToken
            case "Autofill key does not exist":
                return .autofillKeyDoesNotExist
            case "Permission denied":
                return .permissionDenied
            case "Current user is not in this company":
                return .currentUserIsNotInThisCompany
            
            case "Company does not exist":
                return .companyDoesNotExist
                
            default:
                return .unknowmError
            }
        }
        return .unknowmError
    }
}
