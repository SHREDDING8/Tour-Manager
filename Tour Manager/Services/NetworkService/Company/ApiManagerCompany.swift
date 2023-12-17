//
//  ApiManagerCompany.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation
import Alamofire

protocol ApiManagerCompanyProtocol{
    
    func addCompany(companyName:String) async throws
    
    func updateCompanyInfo(companyName:String) async throws -> Bool
    
    func deleteCompany() async throws ->Bool
    
}

public final class ApiManagerCompany:ApiManagerCompanyProtocol{
    
    private let generalData = NetworkServiceHelper()
    private let keychainService:KeychainServiceProtocol = KeychainService()
    
    func addCompany(companyName:String) async throws{
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Companies.addCompany(companyName: companyName))
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let _:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .post, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let decoded = try? JSONDecoder().decode(ResponseAddCompanyJsonStruct.self, from: success ?? Data()){
                            self.keychainService.setCompanyName(companyName: companyName)
                            self.keychainService.setCompanyLocalId(companyLocalId: decoded.company_id)
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
    
    
    public func updateCompanyInfo(companyName:String) async throws -> Bool{
        
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
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
    
        
    public func deleteCompany() async throws ->Bool{
        
        let refreshToken = try await ApiManagerAuth.refreshToken()
        if !refreshToken{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Companies.deleteCompany(companyId: keychainService.getCompanyLocalId() ?? ""))
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
                
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .delete,headers: headers.getHeaders()).response { response in
                
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
    
}
