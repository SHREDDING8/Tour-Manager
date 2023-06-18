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
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                if error.message == "Token expired"{
                    completion(false, nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, nil, .invalidToken)
                }else if error.message == "Autofill key does not exist"{
                    completion(false,nil,.autofillKeyDoesNotExist)
                }else if error.message == "Permission denied"{
                    completion(false,nil,.permissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false,nil,.currentUserIsNotInThisCompany)
                }else if error.message == "Company does not exist" {
                    completion(false,nil,.companyDoesNotExist)
                }else {
                    completion(false, nil, .unknowmError)
                }
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
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                }else if error.message == "Autofill key does not exist"{
                    completion(false, .autofillKeyDoesNotExist)
                }else if error.message == "Permission denied"{
                    completion(false, .permissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, .currentUserIsNotInThisCompany)
                }else if error.message == "Company does not exist" {
                    completion(false, .companyDoesNotExist)
                }else {
                    completion(false, .unknowmError)
                }
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
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                }else if error.message == "Autofill key does not exist"{
                    completion(false, .autofillKeyDoesNotExist)
                }else if error.message == "Permission denied"{
                    completion(false, .permissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, .currentUserIsNotInThisCompany)
                }else if error.message == "Company does not exist" {
                    completion(false, .companyDoesNotExist)
                }else {
                    completion(false, .unknowmError)
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            }else{
                completion(false, .unknowmError)
            }
        }
    }
}
