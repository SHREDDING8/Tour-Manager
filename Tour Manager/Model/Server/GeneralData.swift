//
//  GeneralData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire


class GeneralData{
    // http://188.225.77.189:8080/
    
    // https://server.shredding-quiner.ru/
    public let domain = "https://server.shredding-quiner.ru/"
    
    private let routeRefreshToken:String
    
    let userDefaults = WorkWithUserDefaults()
            
    init(){
        routeRefreshToken = domain + "auth/refresh_user_token/"
    }
    
    
    public func checServerkConnection(completion: @escaping (Bool)->Void){
        
        let urlString = domain + "get_status_server"
        
        let url = URL(string: urlString)!
        
        AF.request(url, method: .get){$0.timeoutInterval = 10}.validate().response{
            response in
            switch response.result {
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
        
    }
    
    public func requestWithCheckRefresh(completion: @escaping (String?)->Void){
        
        let refreshToken = self.userDefaults.getRefreshToken() ?? ""
        
        if !self.userDefaults.isAuthToken(date: Date.now){
            print("requestWithCheckRefresh isAuthToken, refreshToken \(refreshToken)")
            self.refreshToken(refreshToken: refreshToken) { isRefreshed, newToken, error in
                if isRefreshed{
                    self.userDefaults.setAuthToken(token: newToken!)
                    
                    completion(newToken!)
                }else{
                    completion(nil)
                }
            }
        }else{
            completion(nil)
        }
    }
        
    private func refreshToken(refreshToken:String, completion: @escaping (Bool,String?, customErrorAuth?)->Void){
        
        let jsonData = ["refresh_token":refreshToken]
        
        let url = URL(string: routeRefreshToken)!
        
        
        
        
        
        AF.request(url,method: .post, parameters: jsonData,encoder: .json).response{
            response in
                        
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    completion(false,nil, .unknowmError)
                }else if response.response?.statusCode == 200{
                    
                    let newToken = try! JSONDecoder().decode(ResponseRefreshToken.self, from: response.data!)
                    completion(true, newToken.token, nil)
                    self.userDefaults.setLastRefreshDate(date: Date.now)
                    
                }else{
                    completion(false,nil, .unknowmError)
                }
            case .failure(_):
                completion(false,nil, .notConnected)
            }
        }
        
    }
    
}

public struct ResponseWithErrorJsonStruct: Codable {
    let message:String
}
