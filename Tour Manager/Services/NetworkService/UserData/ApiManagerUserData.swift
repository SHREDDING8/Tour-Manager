//
//  ApiManagerUserData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire


public enum UserDataFields:String{
    case firstName = "first_name"
    case secondName = "last_name"
    case birthdayDate = "birthday_date"
    case phone = "phone"
}



protocol ApiManagerUserDataProtocol{
    func getUserInfo() async throws -> ResponseGetUserInfoJsonStruct
    func setUserInfo(info:SetUserInfoSend) async throws
    
    // photo
    func downloadProfilePhoto(pictureId:String) async throws -> Data
    func uploadProfilePhoto(image:UIImage) async throws -> String
    func deleteProfilePhoto(pictureId:String) async throws -> Bool
    
    // userInfo
    func updateUserInfo(updateField: UserDataFields, value:String) async throws -> Bool
    
    func deleteCurrentUser() async throws -> Bool
    
    
}

public class ApiManagerUserData: ApiManagerUserDataProtocol{
    let generalData = NetworkServiceHelper()
    let keychainService = KeychainService()
    
    func getUserInfo() async throws -> ResponseGetUserInfoJsonStruct{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.getUserInfo)!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
                
        let result:ResponseGetUserInfoJsonStruct = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let responseData = try? JSONDecoder().decode(ResponseGetUserInfoJsonStruct.self, from: success ?? Data()){
                            continuation.resume(returning: responseData)
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
    
    func setUserInfo(info:SetUserInfoSend) async throws{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.updateUserInfo)
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let _:Bool =  try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .put, parameters: info, encoder: .json,headers: headers.getHeaders()).response { response in
                
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
        
    }
    
    // MARK: - updateUserInfo
    public func updateUserInfo(updateField: UserDataFields, value:String) async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.updateUserInfo)
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let jsonData = [
            updateField.rawValue : value
        ]
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .put, parameters: jsonData, encoder: .json,headers: headers.getHeaders()).response { response in
                
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
    
    
    public func deleteCurrentUser() async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.deleteUser)
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .delete, headers: headers.getHeaders()).response { response in
                
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
    
    public func uploadProfilePhoto(image:UIImage) async throws -> String{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.addUserProfilePicture)
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let imageData = image.jpegData(compressionQuality: 1)!
        
        let result:String = try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(imageData, withName: "file", fileName: "profile photo.jpg")
                
            }, to: url!,headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let decoded = try? JSONDecoder().decode(ResponseUploadPhoto.self, from: success ?? Data()){
                            continuation.resume(returning: decoded.pictureID)
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
    
    // MARK: - downloadProfilePhoto
    func downloadProfilePhoto(pictureId:String) async throws -> Data{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.getUserProfilePicture(pictureId: pictureId))!
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
                
        let result:Data = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        continuation.resume(returning: success ?? Data())
                        
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
    
    
    public func deleteProfilePhoto(pictureId:String) async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
        }
        
        let url = URL(string: NetworkServiceHelper.Users.deleteUserProfilePicture(pictureId: pictureId))!
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .delete, headers: headers.getHeaders()).response { response in
                
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
    
    //    // MARK: - updateEmail
    //
    //    public func updateEmail(token:String, email:String, completion: @escaping (Bool,customErrorUserData?)->Void ){
    //        let url = URL(string: routeSetUserInfo)
    //        let jsonData = [
    //            "token": token,
    //            "email": email
    //        ]
    //
    //        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
    //
    //            if response.response?.statusCode == 400{
    //                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
    //
    //                if error.message == "Token expired" || error.message == "Invalid Firebase ID token" {
    //                    completion(false, .invalidToken)
    //                } else {
    //                    completion(false, .unknowmError)
    //                }
    //                return
    //            } else if response.response?.statusCode == 200{
    //                completion(true,nil)
    //            } else {
    //                completion(false, .unknowmError)
    //            }
    //
    //        }
    //    }
    
}
