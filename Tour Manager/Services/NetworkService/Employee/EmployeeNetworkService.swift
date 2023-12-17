//
//  EmployeeNetworkService.swift
//  Tour Manager
//
//  Created by SHREDDING on 30.11.2023.
//

import Foundation
import Alamofire

protocol EmployeeNetworkServiceProtocol{
    func getCurrentCompanyUserAccessLevels() async throws -> ResponseAccessLevel
    
    func updateCompanyUserAccessLevel(employeeId:String, _ jsonData:SendUpdateUserAccessLevel) async throws -> Bool
        
    func getCompanyUsers() async throws -> [GetCompanyUsersElement]
    
    func getCompanyGuides() async throws -> [GetCompanyUsersElement]
    
    func getEmployeeInfoById(employeeId:String) async throws -> GetCompanyUsersElement
    
    func addEmployeeToCompany(companyId:String) async throws
}

final class EmployeeNetworkService:EmployeeNetworkServiceProtocol{
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    
    func getCurrentCompanyUserAccessLevels() async throws -> ResponseAccessLevel{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Employee.getCurrentCompanyUserAccessLevels(companyId: keychainService.getCompanyLocalId() ?? ""))
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result: ResponseAccessLevel = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let accessLevels = try? JSONDecoder().decode(ResponseAccessLevel.self, from: success ?? Data()){
                            continuation.resume(returning: accessLevels)
                        }else{
                            continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                        }
                    default:
                        continuation.resume(throwing: NetworkServiceHelper.parseError(data: success))
                        
                    }
                    
                case .failure(let failure):
                    if failure.isSessionTaskError, let urlError = failure.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        // no connection
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.noConnection)
                    } else {
                        // Другие типы ошибок
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                    }
                }
            }
            
        }
        
        return result
    }
    
    func updateCompanyUserAccessLevel(employeeId:String, _ jsonData:SendUpdateUserAccessLevel) async throws -> Bool{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
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
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        continuation.resume(returning: true)
                    default:
                        continuation.resume(throwing: NetworkServiceHelper.parseError(data: success))
                        
                    }
                    
                case .failure(let failure):
                    if failure.isSessionTaskError, let urlError = failure.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        // no connection
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.noConnection)
                    } else {
                        // Другие типы ошибок
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                    }
                }
                
            }
            
        }
        
        return result
    }
    
    func getCompanyUsers() async throws -> [GetCompanyUsersElement]{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.getCompanyUsers(companyId: keychainService.getCompanyLocalId() ?? "")
            )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:[GetCompanyUsersElement] = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        typealias GetCompanyUsers = [GetCompanyUsersElement]
                        
                        if let companyUsers = try? JSONDecoder().decode(GetCompanyUsers.self, from: success ?? Data()){
                            continuation.resume(returning: companyUsers)
                        }else{
                            continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                        }
                        
                        
                    default:
                        continuation.resume(throwing: NetworkServiceHelper.parseError(data: success))
                        
                    }
                    
                case .failure(let failure):
                    if failure.isSessionTaskError, let urlError = failure.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        // no connection
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.noConnection)
                    } else {
                        // Другие типы ошибок
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                    }
                }
                
            }
            
        }
        
        return result
    }
    
    func getCompanyGuides() async throws -> [GetCompanyUsersElement]{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.getCompanyGuides(companyId: keychainService.getCompanyLocalId() ?? "")
            )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:[GetCompanyUsersElement] = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        typealias GetCompanyUsers = [GetCompanyUsersElement]
                        
                        if let companyUsers = try? JSONDecoder().decode(GetCompanyUsers.self, from: success ?? Data()){
                            continuation.resume(returning: companyUsers)
                        }else{
                            continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                        }
                        
                        
                    default:
                        continuation.resume(throwing: NetworkServiceHelper.parseError(data: success))
                        
                    }
                    
                case .failure(let failure):
                    if failure.isSessionTaskError, let urlError = failure.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        // no connection
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.noConnection)
                    } else {
                        // Другие типы ошибок
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                    }
                }
                
            }
            
        }
        
        return result
    }
    
    func getEmployeeInfoById(employeeId:String) async throws -> GetCompanyUsersElement{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.getUserInfoByTarget(targetId: employeeId, companyId: keychainService.getCompanyLocalId() ?? "")
            )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:GetCompanyUsersElement = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let user = try? JSONDecoder().decode(GetCompanyUsersElement.self, from: response.data!){
                            continuation.resume(returning: user)
                        }else{
                            continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                        }
                        
                        
                    default:
                        continuation.resume(throwing: NetworkServiceHelper.parseError(data: success))
                        
                    }
                    
                case .failure(let failure):
                    if failure.isSessionTaskError, let urlError = failure.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        // no connection
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.noConnection)
                    } else {
                        // Другие типы ошибок
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                    }
                }
                
            }
        }
        
        return result
    }
    
    func addEmployeeToCompany(companyId:String) async throws{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL( string: NetworkServiceHelper.Employee.registerToCompany(companyId: companyId))!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let _:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let decoded = try? JSONDecoder().decode(RegisterToCompanyResponse.self, from: success ?? Data()){
                            self.keychainService.setCompanyLocalId(companyLocalId: companyId)
                            self.keychainService.setCompanyName(companyName: decoded.companyName)
                            continuation.resume(returning: true)
                        }else{
                            continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                        }
                        
                        
                    default:
                        continuation.resume(throwing: NetworkServiceHelper.parseError(data: success))
                        
                    }
                    
                case .failure(let failure):
                    if failure.isSessionTaskError, let urlError = failure.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        // no connection
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.noConnection)
                    } else {
                        // Другие типы ошибок
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                    }
                }
                
            }
        }
    }
    
}
