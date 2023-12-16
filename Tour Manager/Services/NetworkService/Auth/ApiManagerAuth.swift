//
//  ApiManagerAuth.swift
//  Tour Manager
//
//  Created by SHREDDING on 30.04.2023.
//

import Foundation
import Alamofire
import DeviceKit

import os
import UIKit

protocol ApiManagerAuthProtocol{
    func logIn(email:String,password:String, deviceToken:String) async throws -> ResponseLogInJsonStruct
    
    func signUp(email:String,password:String) async throws -> Bool
    
    func resetPassword(email:String) async throws -> Bool
    
    func sendVerifyEmail(email:String, password:String) async throws -> Bool
    
    func updatePassword(email:String,oldPassword:String, newPassword:String) async throws -> Bool
    
    func getLoggedDevices() async throws -> ResponseGetAllDevices
    
    func logoutAllDevices(password:String) async throws -> Bool
    
    static func refreshToken() async throws -> Bool
}


public class ApiManagerAuth: ApiManagerAuthProtocol{
    
    let generalData = NetworkServiceHelper()
    
    let keychainService = KeychainService()
    
    // MARK: - logIn
    func logIn(email:String,password:String,deviceToken:String) async throws -> ResponseLogInJsonStruct{
        
        let jsonData = await SendLogInJsonStruct(
            email: email,
            password: password,
            apnsToken: ApnsToken(
                vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "",
                deviceToken: keychainService.getDeviceToken() ?? "",
                deviceName: Device.current.safeDescription
            )
        )
        
        
        let url = URL(string: NetworkServiceHelper.Auth.login)!
        
        let result:ResponseLogInJsonStruct = try await withCheckedThrowingContinuation { continuation in
            AF.request(url,method: .post, parameters: jsonData,encoder: .json).response { response in
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let logInData = try? JSONDecoder().decode(ResponseLogInJsonStruct.self, from: success ?? Data()){
                            
                            continuation.resume(returning: logInData)
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
    
    static func refreshToken() async throws -> Bool{
        let keychainService = KeychainService()
        
        if keychainService.isAcessTokenAvailable(){
            return true
        }
        
        let url = URL(string: NetworkServiceHelper.Auth.refreshUserToken)!
        let headers = NetworkServiceHelper.Headers()
        headers.addRefreshToken()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url,method: .post, headers: headers.getHeaders()).response{
                response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let newToken = try? JSONDecoder().decode(ResponseRefreshToken.self, from: success ?? Data()){
                            keychainService.setAcessToken(token: newToken.token)
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
        
        return result
        
    }
    
//    public func logIn(email:String,password:String, deviceToken:String, completion: @escaping (Bool, ResponseLogInJsonStruct?, customErrorAuth?)->Void ){
//        
//        let jsonData = SendLogInJsonStruct(email: email, password: password, apnsToken: ApnsToken(vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "", deviceToken: deviceToken, deviceName: UIDevice.current.name))
//        
//        let url = URL(string: routeLogIn)
//        
//
//        AF.request(url!,method: .post, parameters: jsonData,encoder: .json).response { response in
//            switch response.result {
//            case .success(_):
//                if response.response?.statusCode == 400{
//                    let error = self.checkError(data: response.data!)
//                    completion(false, nil, error)
//                } else if response.response?.statusCode == 200{
//                    if let logInData = try? JSONDecoder().decode(ResponseLogInJsonStruct.self, from: response.data!){
//                        completion(true, logInData, nil)
////                        self.userDefaults.setLastRefreshDate(date: Date.now)
//                    }
//                } else {
//                    completion(false, nil, .unknowmError)
//                }
//                
//            case .failure(_):
//                completion(false, nil, .notConnected)
//            }
//            
//        }
//    }
    
    
    public func logOut() async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string:  NetworkServiceHelper.Auth.logout)
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let jsonData = await sendLogOut(
            apns_vendor_id: UIDevice.current.identifierForVendor?.uuidString ?? ""
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response{
                response in
                
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
    
    // MARK: - signUp
    func signUp(email:String,password:String) async throws -> Bool{
        
        let jsonData = [
            "email": email,
            "password": password
        ]
        
        let url = URL(string: NetworkServiceHelper.Auth.signUp)
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
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
        
    // MARK: - Reset Password
    func resetPassword(email:String) async throws -> Bool{
        let url = URL(string: NetworkServiceHelper.Auth.resetPassword(email: email))!
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .post).response { response in
                
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
    
    // MARK: - updatePassword
    func updatePassword(email:String,oldPassword:String, newPassword:String) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Auth.updatepassword)!
        
        let jsonData = await sendUpdatePassword(
            email: email,
            password: oldPassword,
            newPassword: newPassword,
            apnsToken: ApnsToken(
                vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "",
                deviceToken: keychainService.getDeviceToken() ?? "",
                deviceName: Device.current.safeDescription
            )
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let decoded = try? JSONDecoder().decode(ResponseLogOutAllJsonStruct.self, from: success ?? Data()){
                            self.keychainService.setAcessToken(token: decoded.token)
                            self.keychainService.setRefreshToken(token: decoded.refreshToken)
                            continuation.resume(returning: true)
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
    
    
    // MARK: - sendVerifyEmail
    func sendVerifyEmail(email:String, password:String) async throws -> Bool{
        
        let jsonData = [
            "email": email,
            "password": password
        ]
        
        let url = URL(string: NetworkServiceHelper.Auth.sendVerifyEmail)
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
                
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
    
//    public func sendVerifyEmail(email:String, password:String, completion:  @escaping (Bool?,customErrorAuth?)->Void ) {
//        
//        let jsonData = [
//            "email": email,
//            "password": password
//        ]
//        let url = URL(string: routeSendVerifyEmail)
//        
//        AF.request(url!, method: .post, parameters:  jsonData,encoder: .json).response { response in
//            
//            switch response.result {
//            case .success(_):
//                if response.response?.statusCode == 200{
//                    completion(true,nil)
//                } else {
//                    completion(nil,.unknowmError)
//                }
//            case .failure(_):
//                completion(nil,.notConnected)
//            }
//        }
//    }
    
    func getLoggedDevices() async throws -> ResponseGetAllDevices{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Auth.getLoggedDevices)!
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:ResponseGetAllDevices = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let loggedDevices = try? JSONDecoder().decode(ResponseGetAllDevices.self, from: success ?? Data()){
                            continuation.resume(returning: loggedDevices)
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
    
    func logoutAllDevices(password:String) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Auth.logoutAllDevices)!
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let jsonData = await logOutAll(
            apnsToken: ApnsToken(
                vendorID: UIDevice.current.identifierForVendor?.uuidString ?? "",
                deviceToken: keychainService.getDeviceToken() ?? "",
                deviceName: Device.current.safeDescription
            ),
            password: password
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response { response in
                
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let decoded = try? JSONDecoder().decode(ResponseLogOutAllJsonStruct.self, from: success ?? Data()){
                            self.keychainService.setAcessToken(token: decoded.token)
                            self.keychainService.setRefreshToken(token: decoded.refreshToken)
                            continuation.resume(returning: true)
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
    
}
