//
//  ApiManagerCompany.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation
import Alamofire

public enum customErrorCompany:Error{
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


protocol ApiManagerCompanyProtocol{
    func getCurrentAccessLevel() async throws -> ResponseAccessLevel
    func getCompanyUsers() async throws -> [GetCompanyUsersElement]
    func updateCompanyInfo(companyName:String) async throws -> Bool
    
    func DeleteCompany() async throws ->Bool
    
    func updateUserAccessLevel(_ jsonData:SendUpdateUserAccessLevel) async throws -> Bool
}

public class ApiManagerCompany:ApiManagerCompanyProtocol{
    
    private let generalData = GeneralData()
    private let keychainService = KeychainService()
    
    private let domain:String
    private let prefix:String
    
    private let routeAddCompany:String
    private let routeAddEmployeeToCompany:String
    
    private let routeUpdateCompanyInfo:String
    private let routeGetCurrentAccesslevel:String
    
    private let routeDeleteCompany:String
    
    private let routeGetCompanyUsers:String
    
    private let routeGetCompanyGuides:String
    private let routeUpdateUserAccessLevel:String
    
    
    init() {
        self.domain = generalData.domain
        self.prefix =  domain + "companies/"
        
        self.routeAddCompany = prefix + "add_company"
        self.routeAddEmployeeToCompany = prefix + "add_employee_to_company"
        
        self.routeUpdateCompanyInfo = prefix + "update_company_info"
        self.routeGetCurrentAccesslevel = prefix + "get_current_access_level"
        
        self.routeDeleteCompany = prefix + "delete_company"
        
        self.routeGetCompanyUsers = prefix + "get_company_users"
        
        self.routeGetCompanyGuides = prefix + "get_company_guides"
        self.routeUpdateUserAccessLevel = prefix + "update_user_access_level"
    }
    
    public func addCompany(token:String, companyName:String, completion: @escaping (Bool,ResponseAddCompanyJsonStruct?,customErrorCompany?)->Void ){
        
        generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            
            let url = URL(string: self.routeAddCompany)
            
            let jsonData = SendAddCompanyJsonStruct(token: requestToken, company_name: companyName)
            
            
            
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
    }
    
    
    public func addEmployeeToCompany(token:String, companyId:String, completion: @escaping (Bool,ResponseAddEmployeeToCompanyJsonStruct?,customErrorCompany?)->Void ){
        
        generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            
            let url = URL(string: self.routeAddEmployeeToCompany)
            
            let jsonData = SendAddEmployeeToCompanyJsonStruct(token: requestToken, company_id: companyId)
            
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
    }
    
    public func updateCompanyInfo(companyName:String) async throws -> Bool{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: self.routeUpdateCompanyInfo)
        
        let jsonData = SendCompanyInfoJsonStruct(
            token: keychainService.getAcessToken() ?? "",
            company_id: keychainService.getCompanyLocalId() ?? "",
            company_name: companyName
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    }else{
                        continuation.resume(throwing: customErrorCompany.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorCompany.unknowmError)
                }
                
            }
        }
        
        return result
    }
    
    // MARK: - getCurrentAccessLevel
    func getCurrentAccessLevel() async throws -> ResponseAccessLevel{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: self.routeGetCurrentAccesslevel)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: keychainService.getAcessToken() ?? "", company_id: keychainService.getCompanyLocalId() ?? "")
                
        let result: ResponseAccessLevel = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        if let accessLevels = try? JSONDecoder().decode(ResponseAccessLevel.self, from: response.data!){
                            continuation.resume(returning: accessLevels)
                        }else{
                            continuation.resume(throwing: customErrorCompany.unknowmError)
                        }
                        
                    }else{
                        continuation.resume(throwing: customErrorCompany.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorCompany.unknowmError)
                }
            }
            
        }
        
        return result
    }
        
    public func DeleteCompany() async throws ->Bool{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: self.routeDeleteCompany)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(
            token: keychainService.getAcessToken() ?? "",
            company_id: keychainService.getCompanyLocalId() ?? ""
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    }else{
                        continuation.resume(throwing: customErrorCompany.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorCompany.unknowmError)
                }
            }
        }
        
        return result
    }
    
    // MARK: - getCompanyUsers
    func getCompanyUsers() async throws -> [GetCompanyUsersElement]{
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: self.routeGetCompanyUsers)
        
        let jsonData = SendAddEmployeeToCompanyJsonStruct(token: keychainService.getAcessToken() ?? "", company_id: keychainService.getCompanyLocalId() ?? "")
        
        let result:[GetCompanyUsersElement] = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                    
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        typealias GetCompanyUsers = [GetCompanyUsersElement]
                        
                        if let companyUsers = try? JSONDecoder().decode(GetCompanyUsers.self, from: response.data!){
                            continuation.resume(returning: companyUsers)
                        }else{
                            continuation.resume(throwing: customErrorCompany.unknowmError)
                        }
                        
                    }else{
                        continuation.resume(throwing: customErrorCompany.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorCompany.unknowmError)
                }
                
            }
            
        }
        
        return result
        
    }
    
    public func updateUserAccessLevel(_ jsonData:SendUpdateUserAccessLevel) async throws -> Bool{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: self.routeUpdateUserAccessLevel)!
        
        var jsonDataRequest =  jsonData
        jsonDataRequest.token = keychainService.getAcessToken() ?? ""
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonDataRequest, encoder: .json).response { response in
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    } else{
                        continuation.resume(throwing: customErrorCompany.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorCompany.unknowmError)
                }
            }
            
        }
        
        return result
        
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





