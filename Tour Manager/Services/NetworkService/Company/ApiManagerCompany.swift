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
    func updateCompanyInfo(companyName:String) async throws -> Bool
    
    func deleteCompany() async throws ->Bool
    
}

public class ApiManagerCompany:ApiManagerCompanyProtocol{
    
    private let generalData = NetworkServiceHelper()
    private let keychainService:KeychainServiceProtocol = KeychainService()
    
    private let domain:String
    private let prefix:String
    
    private let routeAddCompany:String
    private let routeAddEmployeeToCompany:String
    
    init() {
        self.domain = generalData.domain
        self.prefix =  domain + "companies/"
        
        self.routeAddCompany = prefix + "add_company"
        self.routeAddEmployeeToCompany = prefix + "add_employee_to_company"
        
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
        
        let url = URL(string: NetworkServiceHelper.Companies.updateCompanyInfo(companyId: keychainService.getCompanyLocalId() ?? ""))
        
        let jsonData = SendCompanyInfoJsonStruct(
            companyName: companyName
        )
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .put, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response { response in
                
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
    
        
    public func deleteCompany() async throws ->Bool{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: NetworkServiceHelper.Companies.deleteCompany(companyId: keychainService.getCompanyLocalId() ?? ""))
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
                
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .delete,headers: headers.getHeaders()).response { response in
                
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





