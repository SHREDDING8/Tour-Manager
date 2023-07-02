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
    
    case targetUserDoesNotExist
    
    case notConnected
    
    
    public func getValuesForAlert()->AlertFields{
        
        switch self {
        case .tokenExpired:
            return  AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .invalidToken:
            return AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .unknowmError:
            return AlertFields(title: "Произошла неизвестная ошибка на сервере")
        case .permissionDenied:
            return AlertFields(title: "Произошла ошибка", message: "Недостаточно прав доступа для совершения этого действия")
        case .userIsNotInThisCompany:
            return AlertFields(title: "Произошла ошибка", message: "Пользователь не числится в этой компании")
        case .companyIsPrivateOrDoesNotExist:
            return AlertFields(title: "Произошла ошибка", message: "Компания является частной или не существует")
        case .userIsAlreadyAttachedToCompany:
            return AlertFields(title: "Произошла ошибка", message: "Пользователь уже существует в другой компании")
        case .targetUserDoesNotExist:
            return AlertFields(title: "Произошла ошибка", message: "Пользователь не существует")
        case .notConnected:
            return AlertFields(title: "Нет подключения к серверу")
        }
    }
}



public class ApiManagerCompany{
    
    private static let domain = GeneralData.domain
    private static let prefix =  domain + "companies"
    
    private let routeAddCompany = prefix + "/add_company"
    private let routeAddEmployeeToCompany = prefix + "/add_employee_to_company"
    
    private let routeUpdateCompanyInfo = prefix + "/update_company_info"
    private let routeGetCurrentAccesslevel = prefix + "/get_current_access_level"
    
    private let routeDeleteCompany = prefix + "/delete_company"
    
    private let routeGetCompanyUsers = prefix + "/get_company_users"
    
    private let routeGetCompanyGuides = prefix + "/get_company_guides"
    private let routeUpdateUserAccessLevel = prefix + "/update_user_access_level"
    
    public func addCompany(token:String, companyName:String, completion: @escaping (Bool,ResponseAddCompanyJsonStruct?,customErrorCompany?)->Void ){
        
        let url = URL(string: routeAddCompany)
        
        let jsonData = SendAddCompanyJsonStruct(token: token, company_name: companyName)
        


        AF.request(url!, method: .post, parameters: jsonData, encoder: .json)  .response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,nil, error)
                }else if response.response?.statusCode == 200{
                    if let responseData = try? JSONDecoder().decode(ResponseAddCompanyJsonStruct.self, from: response.data!){
                        completion(true,responseData, nil)
                    }
                } else {
                    completion(false, nil, .unknowmError)
                }
            case .failure(_):
                completion(false,nil,.notConnected)
            }
        }
    }
    
    
    public func addEmployeeToCompany(token:String, companyId:String, completion: @escaping (Bool,ResponseAddEmployeeToCompanyJsonStruct?,customErrorCompany?)->Void ){
        
        let url = URL(string: routeAddEmployeeToCompany)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,nil, error)
                    
                } else if response.response?.statusCode == 200{
                    if let responseData = try? JSONDecoder().decode(ResponseAddEmployeeToCompanyJsonStruct.self, from: response.data!){
                        completion(true,responseData,  nil)
                    }
                } else{
                    completion(false, nil, .unknowmError)
                }
            case .failure(_):
                completion(false, nil, .notConnected)
            }
            
            
            
        }
    }
    
    public func updateCompanyInfo(token:String, companyId:String, companyName:String, completion: @escaping (Bool,customErrorCompany?)->Void ){
        
        let url = URL(string: routeUpdateCompanyInfo)
        
        let jsonData = SendCompanyInfoJsonStruct(token: token, company_id: companyId, company_name: companyName)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true, nil)
                }else{
                    completion(false, .unknowmError)
                }
            case .failure(_):
                completion(false, .notConnected)
            }

        }
    }
    
    public func getCurrentAccessLevel(token:String, companyId:String,completion: @escaping (ResponseAccessLevel?,customErrorCompany?)->Void ){
        let url = URL(string: routeGetCurrentAccesslevel)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(nil, error)
                    
                } else if response.response?.statusCode == 200{
                    let accessLevels = try? JSONDecoder().decode(ResponseAccessLevel.self, from: response.data!)
                    completion(accessLevels, nil)
                }else{
                    completion(nil, .unknowmError)
                }
            case .failure(_):
                completion(nil, .notConnected)
            }
        }
    }
    
    public func DeleteCompany(token:String, companyId:String, completion: @escaping (Bool,customErrorCompany?)->Void ){
        
        let url = URL(string: routeDeleteCompany)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true, nil)
                }else{
                    completion(false, .unknowmError)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
        }
    }
    
    public func getCompanyUsers(token:String, companyId:String, completion: @escaping (Bool, [GetCompanyUsersElement]?, customErrorCompany?)->Void ) {
        let url = URL(string: routeGetCompanyUsers)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,nil, error)
                    
                } else if response.response?.statusCode == 200{
                    typealias GetCompanyUsers = [GetCompanyUsersElement]
                    
                    let companyUsers = try! JSONDecoder().decode(GetCompanyUsers.self, from: response.data!)
                    
                    completion(true, companyUsers, nil)
                }else{
                    completion(false, nil, .unknowmError)
                }
            case .failure(_):
                completion(false, nil, .notConnected)
            }
            
            
            
        }
        
    }
    
    
    
    public func getCompanyGuides(token:String, companyId:String, completion: @escaping (Bool, [GetCompanyUsersElement]?, customErrorCompany?)->Void ) {
        let url = URL(string: routeGetCompanyGuides)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: token, company_id: companyId)
                
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,nil, error)
                    
                } else if response.response?.statusCode == 200{
                    typealias GetCompanyUsers = [GetCompanyUsersElement]
                    
                    let companyUsers = try! JSONDecoder().decode(GetCompanyUsers.self, from: response.data!)
                    
                    completion(true, companyUsers, nil)
                }else{
                    completion(false, nil, .unknowmError)
                }
            case .failure(_):
                completion(false, nil, .notConnected)
            }
            
            
        }
        
    }
    
    
    public func updateUserAccessLevel(_ jsonData:SendUpdateUserAccessLevel, completion: @escaping (Bool, customErrorCompany?)->Void ){
        
        let url = URL(string: routeUpdateUserAccessLevel)!
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false,error)
                    
                }else if response.response?.statusCode == 200{
                    
                } else{
                    completion(false, .unknowmError)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
            
           
        }
    }
    
    private func checkError(data:Data)->customErrorCompany{
        if let error = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: data){
            switch error.message{
            case "Token expired":
                return .tokenExpired
            case "Invalid Firebase ID token":
                return .invalidToken
                
            case "Target user does not exist":
                return .targetUserDoesNotExist
            
            case "Permission denied":
                return .permissionDenied
            
            case "User is not in this company":
                return .userIsNotInThisCompany
            
            case "Company does not exist","Company is private":
                return .companyIsPrivateOrDoesNotExist
            
            case "User is already attached to company":
                return .userIsAlreadyAttachedToCompany

            default:
                return .unknowmError
            }
        }
        return .unknowmError
    }
    
}





