//
//  ApiManagerCompany.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation
import Alamofire

public enum customErrorCompany{
    case tokenExpired
    case invalidToken
    case unknowmError
    
    case permissionDenied
    case userIsNotInThisCompany
    
    case companyIsPrivateOrDoesNotExist
    case userIsAlreadyAttachedToCompany
}



public class ApiManagerCompany{
    
    private static let domain = GeneralData.domain
    private static let prefix =  domain + "companies"
    
    private let routeAddCompany = prefix + "/add_company"
    private let routeAddEmployeeToCompany = prefix + "/add_employee_to_company"
    
    private let routeUpdateCompanyInfo = prefix + "/update_company_info"
    private let routeGetCurrentAccesslevel = prefix + "/get_current_access_level"
    
    private let routeDeleteCompany = prefix + "/delete_company"
    
    public func addCompany(token:String, companyName:String, completion: @escaping (Bool,ResponseAddCompanyJsonStruct?,customErrorCompany?)->Void ){
        
        let url = URL(string: routeAddCompany)
        
        let jsonData = SendAddCompanyJsonStruct(token: token, company_name: companyName)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired"{
                    completion(false, nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, nil, .invalidToken)
                } else {
                    completion(false, nil, .unknowmError)
                }
                return
            }else if response.response?.statusCode == 200{
                if let responseData = try? JSONDecoder().decode(ResponseAddCompanyJsonStruct.self, from: response.data!){
                    completion(true,responseData, nil)
                }
            } else {
                completion(false, nil, .unknowmError)
            }
        }
    }
    
    
    public func addEmployeeToCompany(token:String, companyId:String, completion: @escaping (Bool,ResponseAddEmployeeToCompanyJsonStruct?,customErrorCompany?)->Void ){
        
        let url = URL(string: routeAddEmployeeToCompany)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Company is private" || error.message == "Company does not exist"{
                    completion(false, nil, .companyIsPrivateOrDoesNotExist)
                }else if error.message == "User is already attached to company"{
                    completion(false, nil, .userIsAlreadyAttachedToCompany)
                }else if error.message == "Token expired"{
                    completion(false, nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false,nil, .invalidToken)
                } else {
                    completion(false, nil, .unknowmError)
                }
                
                return
            } else if response.response?.statusCode == 200{
                if let responseData = try? JSONDecoder().decode(ResponseAddEmployeeToCompanyJsonStruct.self, from: response.data!){
                    completion(true,responseData,  nil)
                }
            } else{
                completion(false, nil, .unknowmError)
            }
            
        }
    }
    
    public func updateCompanyInfo(token:String, companyId:String, companyName:String, completion: @escaping (Bool,customErrorCompany?)->Void ){
        
        let url = URL(string: routeUpdateCompanyInfo)
        
        let jsonData = SendCompanyInfoJsonStruct(token: token, company_id: companyId, company_name: companyName)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Permission denied"{
                    completion(false, .permissionDenied)
                } else if error.message == "User is not in this company"{
                    completion(false, .userIsNotInThisCompany)
                } else if error.message == "Company does not exist"{
                    completion(false, .companyIsPrivateOrDoesNotExist)
                }else if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                }else{
                    completion(false, .unknowmError)
                }
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            }else{
                completion(false, .unknowmError)
            }
            
        }
    }
    
    public func getCurrentAccessLevel(token:String, companyId:String,completion: @escaping (ResponseAccessLevel?,customErrorCompany?)->Void ){
        let url = URL(string: routeGetCurrentAccesslevel)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                if error.message == "Permission denied"{
                    completion(nil, .permissionDenied)
                } else if error.message == "User is not in this company"{
                    completion(nil, .userIsNotInThisCompany)
                } else if error.message == "Company does not exist"{
                    completion(nil, .companyIsPrivateOrDoesNotExist)
                }else if error.message == "Token expired"{
                    completion(nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(nil, .invalidToken)
                }else{
                    completion(nil, .unknowmError)
                }
            } else if response.response?.statusCode == 200{
                let accessLevels = try? JSONDecoder().decode(ResponseAccessLevel.self, from: response.data!)
                completion(accessLevels, nil)
            }else{
                completion(nil, .unknowmError)
            }
        }
        
    }
    
    public func DeleteCompany(token:String, companyId:String, completion: @escaping (Bool,customErrorCompany?)->Void ){
        
        let url = URL(string: routeDeleteCompany)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                }else{
                    completion(false, .unknowmError)
                }
                
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            }else{
                completion(false, .unknowmError)
            }
        }
    
    }
}





