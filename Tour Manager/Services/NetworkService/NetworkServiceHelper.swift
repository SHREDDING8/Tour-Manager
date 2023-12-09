//
//  GeneralData.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.05.2023.
//

import Foundation
import Alamofire


class NetworkServiceHelper{
    // http://188.225.77.189:8080/
    
    // https://server.shredding-quiner.ru/
    public let domain = "https://server.shredding-quiner.ru/"
    
//    private static let newDomain = "https://24tour-manager.ru/api/"
    private static let newDomain = "http://193.164.150.181:32799/"
    
    
    private let routeRefreshToken:String
    
            
    init(){
        routeRefreshToken = domain + "auth/refresh_user_token"
    
    }
    
    // MARK: - URLS Base
    public class Companies{
        fileprivate static let companiesUrlBase = newDomain + "companies"
        
        public static func addCompany(companyName:String) -> String{
            return companiesUrlBase + "/" + companyName
        }
        
        public static func deleteCompany(companyId:String) ->String{
            return companiesUrlBase + "/" + companyId
        }
        
        public static func updateCompanyInfo(companyId:String) -> String{
            return companiesUrlBase + "/" + companyId
        }
        
    }
    
    public class Tours{
        private static func toursBaseUrl(companyId:String) -> String{
            return "\(Companies.companiesUrlBase)/\(companyId)/tours"
        }
        
        public static func getTourDates(companyId:String, guideOnly:Bool,startDate:String, endDate:String) -> String{
            return "\(toursBaseUrl(companyId: companyId))/?guide_only=\(guideOnly)&pure_dates=false&since_date=\(startDate)&end_date=\(endDate)"
        }
        
               
        public static func getDateTourList(companyId:String, tourDate:Date, guideOnly:Bool) -> String {
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate)?guide_only=\(guideOnly)"
        }
        
        // One tour
        public static func addTour(companyId:String, tourDate:Date) -> String{
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate.birthdayToString())"
        }
        
        public static func updateTour(companyId:String, tourDate:Date, new_tour_date:Date, tourId:String) -> String {
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate.birthdayToString())/\(tourId)?new_tour_date=\(new_tour_date.birthdayToString())"
        }
        
        public static func deleteTour(companyId:String, tourDate:String, tourId:String) -> String {
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate)/\(tourId)"
        }
        
        public static func getTour(companyId:String, tourDate:String, tourId:String, guideOnly:Bool) -> String {
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate)/\(tourId)?guide_only=\(guideOnly)"
        }
        
        
        public static func getDateTourList(companyId:String, tourDate:String, guideOnly:Bool) -> String {
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate)?guide_only=\(guideOnly)"
        }
        
        public static func setTourGuideStatus(companyId:String, tourDate:String, tourId:String) -> String {
            return "\(toursBaseUrl(companyId: companyId))/\(tourDate)/\(tourId)/guide_status"
        }
    }
    
    public class Employee{
        private static func toursBaseUrl(companyId:String) -> String{
            return "\(Companies.companiesUrlBase)/\(companyId)/employee"
        }
        
        public static func getCurrentCompanyUserAccessLevels(companyId:String) -> String{
            return toursBaseUrl(companyId: companyId) + "/"
        }
        
        public static func registerToCompany(companyId:String) ->String {
            return toursBaseUrl(companyId: companyId) + "/"
        }
        
        public static func updateCompanyUserAccessLevels(companyId:String, employeeId:String) -> String{
            return toursBaseUrl(companyId: companyId) + "/" + employeeId
        }
        
        public static func getCompanyUsers(companyId:String) -> String{
            return toursBaseUrl(companyId: companyId) + "/all"
        }
        
        public static func getCompanyGuides(companyId:String) -> String{
            return toursBaseUrl(companyId: companyId) + "/guides"
        }
    }
    
    public class Users{
        private static var usersBaseUrl = newDomain + "users"
        
        public static var getUserInfo = usersBaseUrl + "/";
        public static var updateUserInfo = usersBaseUrl + "/";
        
        public static var deleteUser = usersBaseUrl + "/";
        public static func getUserInfoByTarget(targetId:String, companyId:String) ->String{
            return "\(usersBaseUrl)/\(targetId)?companyId=\(companyId)"
        }
        
        private static var profilePictureBaseUrl = "\(usersBaseUrl)/profile_picture"
        
        public static var addUserProfilePicture = profilePictureBaseUrl
        public static func deleteUserProfilePicture(pictureId:String) -> String{
            return "\(profilePictureBaseUrl)/\(pictureId)"
        }
        
        public static func getUserProfilePicture(pictureId:String) ->String{
            return "\(profilePictureBaseUrl)/\(pictureId)"
        }
        
    }
    
    
    public class Headers{
        private var headers:[String:String] = [:]
        let keyChainService:KeychainServiceProtocol = KeychainService()
        
        private enum Keys{
            static let accessToken = "token"
        }
        
        public func getHeaders()->HTTPHeaders{
            return HTTPHeaders(headers)
        }
        
        public func addAccessTokenHeader(){
            headers[Keys.accessToken] = keyChainService.getAcessToken() ?? ""
        }
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
        let keychain = KeychainService()
        completion(keychain.getAcessToken())
//        let refreshToken = self.userDefaults.getRefreshToken() ?? ""
//
//        if !self.userDefaults.isAuthToken(date: Date.now){
//            self.refreshToken(refreshToken: refreshToken) { isRefreshed, newToken, error in
//                if isRefreshed{
//                    self.userDefaults.setAuthToken(token: newToken!)
//                    
//                    completion(newToken!)
//                }else{
//                    completion(nil)
//                }
//            }
//        }else{
//            completion(nil)
//        }
    }
        
    private func refreshToken(refreshToken:String, completion: @escaping (Bool,String?, customErrorAuth?)->Void){

//        AF.request(url,method: .post, parameters: jsonData,encoder: .json).response{
//            response in
//                        
//            switch response.result {
//            case .success(_):
//                if response.response?.statusCode == 400{
//                    completion(false,nil, .unknowmError)
//                }else if response.response?.statusCode == 200{
//                    
//                    let newToken = try! JSONDecoder().decode(ResponseRefreshToken.self, from: response.data!)
//                    completion(true, newToken.token, nil)
//                    self.userDefaults.setLastRefreshDate(date: Date.now)
//                    
//                }else{
//                    completion(false,nil, .unknowmError)
//                }
//            case .failure(_):
//                completion(false,nil, .notConnected)
//            }
//        }
        
    }
    
}

public struct ResponseWithErrorJsonStruct: Codable {
    let message:String
}
