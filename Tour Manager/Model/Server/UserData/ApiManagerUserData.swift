//
//  ApiManagerUserData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire


public enum customErrorUserData{
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




public class ApiManagerUserData{
    private static let domain = GeneralData.domain
    private static let prefix = GeneralData.domain + "users"
    
    private let routeGetUserInfo = prefix + "/get_user_info"
    private let routeSetUserInfo = prefix + "/update_user_info"
    
    private let routeDeleteCurrentUser = prefix + "/delete_current_user_account"
    
    private let routeUploadPhoto = prefix + "/set_profile_picture"
    private let routeDownLoadPhoto = prefix + "/get_profile_picture"
    private let routeDeletePhoto = prefix + "/delete_profile_picture"
    
//    private let routeUpdateEmail = prefix + "/update_user_email"
    
    
    // MARK: - getUserInfo
    public func getUserInfo(token:String, completion: @escaping (Bool,ResponseGetUserInfoJsonStruct?,customErrorUserData?)->Void ){
        let url = URL(string: routeGetUserInfo)
        
        
        let jsonData = SendGetUserInfoJsonStruct(token: token)
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, nil, error)
                    
                } else if response.response?.statusCode == 200{
                    if let responseData = try? JSONDecoder().decode(ResponseGetUserInfoJsonStruct.self, from: response.data!){
                        completion(true, responseData, nil)
                        
                    }else{
                        completion(false, nil, .unknowmError)
                    }
                } else {
                    completion(false, nil, .unknowmError)
                }
            case .failure(_):
                completion(false, nil, .notConnected)
            }
        }
    }
    
    
    // MARK: - setUserInfo
    public func setUserInfo(data:UserDataServerStruct ,completion: @escaping (Bool,customErrorUserData?)->Void ){
        let url = URL(string: routeSetUserInfo)
        
        let jsonData = data
        
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
    
    // MARK: - updateUserInfo
    public func updateUserInfo(token:String, updateField: UserDataFields, value:String, completion: @escaping (Bool,customErrorUserData?)->Void ){
        
        let url = URL(string: routeSetUserInfo)
        let jsonData = [
            "token": token,
            updateField.rawValue : value
        ]
        
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
    
    
    public func deleteCurrentUser(token:String, completion: @escaping (Bool,customErrorUserData?)->Void  ){
        
        let url = URL(string: routeDeleteCurrentUser)
        let jsonData = [
            "token": token,
        ]
        
        AF.request(url!, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true,nil)
                }else{
                    completion(false, .unknowmError)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
        }
        
    }
    
    public func uploadProfilePhoto(token:String, image:UIImage, completion: @escaping (Bool,customErrorUserData?)->Void){
        
        let url = URL(string: routeUploadPhoto)
        let parameter = ["token" : token]
        
        let imageData = image.jpegData(compressionQuality: 1)!
        
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
                    completion(false, error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true,nil)
                }else{
                    completion(false, .unknowmError)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
        }
        
    }
    
    
    public func downloadProfilePhoto(token:String, localId:String, completion: @escaping (Bool,Data?,customErrorUserData?)->Void){
        
        let url = URL(string: routeDownLoadPhoto)!
        
        let json = [
            "token": token,
            "target_uid" : localId
        ]
        
        AF.request(url, method: .post, parameters: json, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, nil, error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true, response.data! ,nil)
                }else{
                    completion(false, nil, .unknowmError)
                }
            case .failure(_):
                completion(false, nil, .notConnected)
            }
        }
        
    }
    
    
    public func deleteProfilePhoto(token:String, completion: @escaping (Bool,customErrorUserData?)->Void){
        
        let url = URL(string: routeDeletePhoto)!
        
        let json = [
            "token": token,
        ]
        
        AF.request(url, method: .post, parameters: json, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, error)
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
