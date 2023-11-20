//
//  ApiManagerUserData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire


public enum customErrorUserData:Error{
    case tokenExpired
    case invalidToken
    
    case dataNotFound
    
    case unknowmError
    
    case notConnected
    
    public func getValuesForAlert()->AlertFields{
        switch self {
        case .tokenExpired:
            return  AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .invalidToken:
            return AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .dataNotFound:
            return AlertFields(title: "Произошла ошибка", message: "Данные не были найдены")
        case .unknowmError:
            return AlertFields(title: "Произошла неизвестная ошибка на сервере")
        case .notConnected:
            return AlertFields(title: "Нет подключения к сервера")
        }
    }
    
}

public enum UserDataFields:String{
    case firstName = "first_name"
    case secondName = "last_name"
    case birthdayDate = "birthday_date"
    case phone = "phone"
}



protocol ApiManagerUserDataProtocol{
    func getUserInfo() async throws -> ResponseGetUserInfoJsonStruct
    
    // photo
    func downloadProfilePhoto(localId:String) async throws -> Data
    func uploadProfilePhoto(image:UIImage) async throws ->Bool
    func deleteProfilePhoto() async throws -> Bool
    
    // userInfo
    func updateUserInfo(updateField: UserDataFields, value:String) async throws -> Bool
    
    func deleteCurrentUser() async throws -> Bool
    
    
}

public class ApiManagerUserData: ApiManagerUserDataProtocol{
    let generalData = GeneralData()
    let keychainService = KeychainService()
    private let domain:String
    private let prefix:String
    
    private let routeGetUserInfo:String
    private let routeSetUserInfo:String
    
    private let routeDeleteCurrentUser:String
    
    private let routeUploadPhoto:String
    private let routeDownLoadPhoto:String
    private let routeDeletePhoto:String
    
    //    private let routeUpdateEmail = prefix + "/update_user_email"
    
    init(){
        self.domain = generalData.domain
        self.prefix = domain + "users/"
        
        self.routeGetUserInfo = prefix + "get_user_info"
        self.routeSetUserInfo = prefix + "update_user_info"
        
        self.routeDeleteCurrentUser = prefix + "delete_current_user_account"
        
        self.routeUploadPhoto = prefix + "set_profile_picture"
        self.routeDownLoadPhoto = prefix + "get_profile_picture"
        self.routeDeletePhoto = prefix + "delete_profile_picture"
    }
    
    func getUserInfo() async throws -> ResponseGetUserInfoJsonStruct{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeGetUserInfo)
        let jsonData = SendGetUserInfoJsonStruct(token: keychainService.getAcessToken() ?? "")
        
        let result:ResponseGetUserInfoJsonStruct = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        let responseData = try! JSONDecoder().decode(ResponseGetUserInfoJsonStruct.self, from: response.data!)
                        continuation.resume(returning: responseData)
                    }else {
                        continuation.resume(throwing: customErrorUserData.unknowmError)
                    }
                    
                case .failure(_):
                    continuation.resume(throwing: customErrorUserData.unknowmError)
                }
            }
            
        }
        
        
        return result
    }
    
    // MARK: - getUserInfo
    public func getUserInfo(token:String, completion: @escaping (Bool,ResponseGetUserInfoJsonStruct?,customErrorUserData?)->Void ){
        
        self.generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
                        
            let url = URL(string: self.routeGetUserInfo)
            
            
            let jsonData = SendGetUserInfoJsonStruct(token: requestToken)
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        completion(false, nil, error)
                        
                    } else if response.response?.statusCode == 200{
                        let responseData = try! JSONDecoder().decode(ResponseGetUserInfoJsonStruct.self, from: response.data!)
                        completion(true, responseData, nil)
                    }else {
                        completion(false, nil, .unknowmError)
                    }
                    
                case .failure(_):
                    completion(false, nil, .notConnected)
                }
            }
        }
    }
    
    
    // MARK: - setUserInfo
    public func setUserInfo(data:UserDataServerStruct ,completion: @escaping (Bool,customErrorUserData?)->Void ){
        
        self.generalData.requestWithCheckRefresh { newToken in
            
            let url = URL(string: self.routeSetUserInfo)
            
            var jsonData = data
            jsonData.token  = newToken == nil ? jsonData.token : newToken!
            
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        completion(false, error)
                        
                    } else if response.response?.statusCode == 200{
                        completion(true,nil)
                    } else {
                        
                        completion(false, .unknowmError)
                    }
                case .failure(_):
                    completion(false, .notConnected)
                }
            }
        }
    }
    
    // MARK: - updateUserInfo
    public func updateUserInfo(updateField: UserDataFields, value:String) async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeSetUserInfo)
        
        let jsonData = [
            "token": keychainService.getAcessToken() ?? "",
            updateField.rawValue : value
        ]
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(throwing: customErrorUserData.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorUserData.unknowmError)
                }
            }
        }
        
        return result
    }
    
    
    public func deleteCurrentUser() async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeDeleteCurrentUser)
        let jsonData = [
            "token": keychainService.getAcessToken() ?? "",
        ]
        
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
                        continuation.resume(throwing: customErrorUserData.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorUserData.unknowmError)
                }
            }
        }
        
        return result
    }
    
    public func uploadProfilePhoto(image:UIImage) async throws ->Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeUploadPhoto)
        let parameter = ["token" : keychainService.getAcessToken() ?? ""]
        
        let imageData = image.jpegData(compressionQuality: 1)!
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                for (key,value) in parameter{
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
                
                multipartFormData.append(imageData, withName: "file", fileName: "profile photo.jpg")
                
            }, to: url!).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                        
                    }else{
                        continuation.resume(throwing: customErrorUserData.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorUserData.unknowmError)
                }
            }
        }
        
        return result
        
    }
    
    // MARK: - downloadProfilePhoto
    func downloadProfilePhoto(localId:String) async throws -> Data{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeDownLoadPhoto)!
        
        let json = [
            "token": keychainService.getAcessToken() ?? "",
            "target_uid" : localId
        ]
        
        let result:Data = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .post, parameters: json, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: response.data!)
                    }else{
                        continuation.resume(throwing: customErrorUserData.unknowmError)
                    }
                    
                case .failure(_):
                    continuation.resume(throwing: customErrorUserData.unknowmError)
                }
            }
            
        }
        
        return result
        
    }
    
    
    public func downloadProfilePhoto(token:String, localId:String, completion: @escaping (Bool,Data?,customErrorUserData?)->Void){
        
        self.generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            
            let url = URL(string: self.routeDownLoadPhoto)!
            
            let json = [
                "token": requestToken,
                "target_uid" : localId
            ]
            
            AF.request(url, method: .post, parameters: json, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        completion(false, nil, error)
                        
                    } else if response.response?.statusCode == 200{
                        completion(true, response.data! , nil)
                    }else{
                        completion(false, nil, .unknowmError)
                    }
                case .failure(_):
                    completion(false, nil, .notConnected)
                }
            }
        }
        
    }
    
    
    public func deleteProfilePhoto() async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeDeletePhoto)!
        let json = [
            "token": keychainService.getAcessToken() ?? "",
        ]
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .post, parameters: json, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    }else{
                        continuation.resume(throwing: customErrorUserData.unknowmError)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorUserData.unknowmError)
                }
            }
            
        }
        
        return result
    }
    
    
    private func checkError(data:Data)->customErrorUserData{
        if let error = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: data){
            switch error.message{
            case "File not found","User data not found":
                return .dataNotFound
            case "Token expired":
                return .tokenExpired
                
            case "Invalid Firebase ID token":
                return .invalidToken
                
            default:
                return .unknowmError
            }
        }
        return .unknowmError
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
