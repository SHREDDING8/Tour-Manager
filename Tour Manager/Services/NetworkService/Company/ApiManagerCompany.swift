//
//  ApiManagerCompany.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation
import Alamofire

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
    
//    public func addCompany(token:String, companyName:String, completion: @escaping (Bool,ResponseAddCompanyJsonStruct?)->Void ){
//        
//        generalData.requestWithCheckRefresh { newToken in
//            let requestToken = newToken == nil ? token : newToken!
//            
//            
//            let url = URL(string: self.routeAddCompany)
//            
//            let jsonData = SendAddCompanyJsonStruct(token: requestToken, company_name: companyName)
//            
//            
//            
//            AF.request(url!, method: .post, parameters: jsonData, encoder: .json)  .response { response in
//                
//                switch response.result {
//                case .success(_):
//                    if response.response?.statusCode == 400{
//                        
//                        let error = self.checkError(data: response.data ?? Data())
//                        completion(false,nil, error)
//                    }else if response.response?.statusCode == 200{
//                        if let responseData = try? JSONDecoder().decode(ResponseAddCompanyJsonStruct.self, from: response.data!){
//                            completion(true,responseData, nil)
//                        }
//                    } else {
//                        completion(false, nil, .unknowmError)
//                    }
//                case .failure(_):
//                    completion(false,nil,.notConnected)
//                }
//            }
//        }
//    }
    
    
//    public func addEmployeeToCompany(token:String, companyId:String, completion: @escaping (Bool,ResponseAddEmployeeToCompanyJsonStruct?)->Void ){
//        
//        generalData.requestWithCheckRefresh { newToken in
//            let requestToken = newToken == nil ? token : newToken!
//            
//            
//            let url = URL(string: self.routeAddEmployeeToCompany)
//            
//            let jsonData = SendAddEmployeeToCompanyJsonStruct(token: requestToken, company_id: companyId)
//            
//            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
//                
//                switch response.result {
//                case .success(_):
//                    if response.response?.statusCode == 400{
//                        
//                        let error = self.checkError(data: response.data ?? Data())
//                        completion(false,nil, error)
//                        
//                    } else if response.response?.statusCode == 200{
//                        if let responseData = try? JSONDecoder().decode(ResponseAddEmployeeToCompanyJsonStruct.self, from: response.data!){
//                            completion(true,responseData,  nil)
//                        }
//                    } else{
//                        completion(false, nil, .unknowmError)
//                    }
//                case .failure(_):
//                    completion(false, nil, .notConnected)
//                }
//                
//                
//                
//            }
//        }
//    }
    
    
    
    public func updateCompanyInfo(companyName:String) async throws -> Bool{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
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
                    
                case .failure(_):
                    continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                }
                
            }
        }
        
        return result
    }
    
        
    public func deleteCompany() async throws ->Bool{
        
        let refreshToken = try! await ApiManagerAuth.refreshToken()
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
                    
                case .failure(_):
                    continuation.resume(throwing: NetworkServiceHelper.NetworkError.unknown)
                }
            }
        }
        
        return result
    }
    
}
