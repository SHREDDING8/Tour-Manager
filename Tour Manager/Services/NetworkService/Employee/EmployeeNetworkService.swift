//
//  EmployeeNetworkService.swift
//  Tour Manager
//
//  Created by SHREDDING on 30.11.2023.
//

import Foundation
import Alamofire

public enum CustomErrorEmployee:Error{
    case tokenExpired
    case invalidToken
    case unknowmError
    
    case permissionDenied
    case userIsNotInThisCompany
    
    case companyIsPrivateOrDoesNotExist
    case userIsAlreadyAttachedToCompany
    
    case targetUserDoesNotExist
    
    case notConnected
}

protocol EmployeeNetworkServiceProtocol{
    func getCurrentCompanyUserAccessLevels() async throws -> ResponseAccessLevel
    
    func updateCompanyUserAccessLevel(employeeId:String, _ jsonData:SendUpdateUserAccessLevel) async throws -> Bool
        
    func getCompanyUsers() async throws -> [GetCompanyUsersElement]
    
    func getCompanyGuides() async throws -> [GetCompanyUsersElement]
    
    func getEmployeeInfoById(employeeId:String) async throws -> GetCompanyUsersElement
}

class EmployeeNetworkService:EmployeeNetworkServiceProtocol{
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    
    func getCurrentCompanyUserAccessLevels() async throws -> ResponseAccessLevel{
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(string: NetworkServiceHelper.Employee.getCurrentCompanyUserAccessLevels(companyId: keychainService.getCompanyLocalId() ?? ""))
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result: ResponseAccessLevel = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        if let accessLevels = try? JSONDecoder().decode(ResponseAccessLevel.self, from: response.data!){
                            continuation.resume(returning: accessLevels)
                        }else{
                            continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                        }
                        
                    }else{
                        continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                }
            }
            
        }
        
        return result
    }
    
    func updateCompanyUserAccessLevel(employeeId:String, _ jsonData:SendUpdateUserAccessLevel) async throws -> Bool{
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Employee.updateCompanyUserAccessLevels(
                companyId: keychainService.getCompanyLocalId() ?? "",
                employeeId: employeeId
            )
        )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .put, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response { response in
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    } else{
                        continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                }
            }
            
        }
        
        return result
    }
    
    func getCompanyUsers() async throws -> [GetCompanyUsersElement]{
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.getCompanyUsers(companyId: keychainService.getCompanyLocalId() ?? "")
            )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:[GetCompanyUsersElement] = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                print(try? JSONSerialization.jsonObject(with: response.data ?? Data() ))
                      
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
                            continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                        }
                        
                    }else{
                        continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                }
                
            }
            
        }
        
        return result
    }
    
    func getCompanyGuides() async throws -> [GetCompanyUsersElement]{
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.getCompanyGuides(companyId: keychainService.getCompanyLocalId() ?? "")
            )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:[GetCompanyUsersElement] = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
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
                            continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                        }
                        
                    }else{
                        continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                }
                
            }
            
        }
        
        return result
    }
    
    func getEmployeeInfoById(employeeId:String) async throws -> GetCompanyUsersElement{
        let refreshToken = try! await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw customErrorCompany.unknowmError
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.getUserInfoByTarget(targetId: employeeId, companyId: keychainService.getCompanyLocalId() ?? "")
            )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:GetCompanyUsersElement = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                switch response.result {
                    
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        
                        if let user = try? JSONDecoder().decode(GetCompanyUsersElement.self, from: response.data!){
                            continuation.resume(returning: user)
                        }else{
                            continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                        }
                        
                    }else{
                        continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: CustomErrorEmployee.unknowmError)
                }
            }
        }
        
        return result
    }
    
    private func checkError(data:Data) -> CustomErrorEmployee{
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
