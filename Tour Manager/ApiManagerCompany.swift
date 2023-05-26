//
//  ApiManagerCompany.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation
import Alamofire



public class ApiManagerCompany{
    
    private static let domain = GeneralData.domain
    private static let prefix =  domain + "companies"
    
    private let routeAddCompany = prefix + "/add_company"
    private let routeAddEmployeeToCompany = prefix + "/add_employee_to_company"
    
    private let user = AppDelegate.user!
    
    public enum customErrorCompany{
        case tokenExpired
        case invalidToken
        case unknowmError
        
        case companyIsPrivateOrDoesNotExist
        case userIsAlreadyAttachedToCompany
    }
    
    
    
    public func addCompany(token:String, companyName:String, completion: @escaping (Bool,customErrorCompany?)->Void ){
        
        let url = URL(string: routeAddCompany)
        
        let jsonData = SendAddCompanyJsonStruct(token: token, company_name: companyName)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                } else {
                    completion(false, .unknowmError)
                }
                return
            }else if response.response?.statusCode == 200{
                if let responseData = try? JSONDecoder().decode(ResponseAddCompanyJsonStruct.self, from: response.data!){
                    self.user.setLocalIDCompany(localIdCompany: responseData.company_id)
                    completion(true, nil)
                }
            } else {
                completion(false, .unknowmError)
            }
        }
    }
    
    
    public func addEmployeeToCompany(token:String, companyId:String, completion: @escaping (Bool,customErrorCompany?)->Void ){
        
        let url = URL(string: routeAddEmployeeToCompany)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.response?.statusCode == 400{
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Company is private" || error.message == "Company does not exist"{
                    completion(false, .companyIsPrivateOrDoesNotExist)
                }else if error.message == "User is already attached to company"{
                    completion(false, .userIsAlreadyAttachedToCompany)
                }else if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                } else {
                    completion(false, .unknowmError)
                }
                
                return
            } else if response.response?.statusCode == 200{
                if let responseData = try? JSONDecoder().decode(ResponseAddEmployeeToCompanyJsonStruct.self, from: response.data!){
                    self.user.setNameCompany(nameCompany: responseData.company_name)
                    completion(true, nil)
                }
            } else{
                completion(false, .unknowmError)
            }
            
        }
    }
    
}


