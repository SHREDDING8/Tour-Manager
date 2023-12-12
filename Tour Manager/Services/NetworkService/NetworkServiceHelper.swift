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
    
    private static let newDomain = "https://24tour-manager.ru/api/"
    //    private static let newDomain = "http://193.164.150.181:32799/"
    
    
    private let routeRefreshToken:String = ""
    
    // MARK: - Error
    enum NetworkError:String, Error{
        // main
        case tokenExpired = "Token expired"
        case invalidFirebaseIdToken = "Invalid Firebase ID token"
        case internalServerError = "Internal server error"
        case permissionDenied = "Permission denied"
        
        case userDoesNotExist = "User does not exist"
        case companyDoesNotExist = "Company does not exist"
        case userIsNotInThisCompany = "User is not in this company"
        
        case invalidDate = "invalid date"
        
        // Autofill
        case autofillKeyDoesNotExist = "Autofill key does not exist"
        
        // Auth
        case emailExists = "Email exists"
        case weakPassword = "Weak password"
        
        case emailIsNotVerified = "Email is not verified"
        case invalidEmailOrPassword = "Invalid email or password"
        case TOO_MANY_ATTEMPTS_TRY_LATER = "TOO_MANY_ATTEMPTS_TRY_LATER"
        
        // refresh_user_token
        case TOKEN_EXPIRED = "TOKEN_EXPIRED"
        case USER_DISABLED = "USER_DISABLED"
        case USER_NOT_FOUND = "USER_NOT_FOUND"
        case INVALID_REFRESH_TOKEN = "INVALID_REFRESH_TOKEN"
        
        // check_email
        case EMAIL_NOT_FOUND = "EMAIL_NOT_FOUND"
        case INVALID_PASSWORD = "INVALID_PASSWORD"
        
        case userWasNotFound = "User was not found"
        case userIsOwnerOfCompany = "User is owner of company"
        
        case invalidPictureId = "Invalid picture id"
        case fileNotFound = "File not found"
        
        case userIsNotInYourCompany = "User is not in your company"
        
        case userIsAlreadyAttachedToCompany = "User is already attached to company"
        
        // Employee
        case companyisPrivate = "Company is private"
        
        // Tours
        
        case dateShouldBeGreaterStart_date = "date should be greater start_date"
        case dateShouldBeLessMax_date = "date should be less max_date"
        case since_dateShouldBeLessThanEnd_dateWithDifferenceNotMoreThan31Day = "since_date should be less than end_date with difference not more than 31 day"
        case tourYearDoesNotExist = "Tour year does not exist"
        case tourMonthDoesNotExist = "Tour month does not exist"
        case tourDayDoesNotExist = "Tour day does not exist"
//        case User(s): [ids] not in your company = "User(s): [ids] not in your company"
        
        case tourDoesNotExist = "TourDoesNotExist" // выходить из тура
        
        case guideIsNotInTour = "GuideIsNotInTour" // выходить из тура
        
        case unknown = "unknown"
        
        case noConnection
        
        // init
        static func getError(msg:String) -> NetworkError{
            if let err = NetworkError(rawValue: msg){
                return err
            }
            return NetworkError.unknown
        }
        
        func getAlertBody() ->(title:String, msg:String?){
            switch self {
            case .tokenExpired:
                ("Ваша сессия закончилась", nil)
            case .invalidFirebaseIdToken:
                ("Ваша сессия закончилась", nil)
            case .internalServerError:
                ("Ошибка сервера", "Повторите попытку позже")
            case .permissionDenied:
                ("Недостаточно прав", nil)
            case .userDoesNotExist:
                ("Пользователя не существует", nil)
            case .companyDoesNotExist:
                ("Организации не существует", nil)
            case .userIsNotInThisCompany:
                ("Пользователь не в этой организации", nil)
            case .invalidDate:
                ("Неправильно введена дата", nil)
            case .autofillKeyDoesNotExist:
                ("", nil)
            case .emailExists:
                ("Email уже существует", nil)
            case .weakPassword:
                ("Слишком слабый пароль", nil)
            case .emailIsNotVerified:
                ("Email не подтвержден", nil)
            case .invalidEmailOrPassword:
                ("Неверный email или пароль", nil)
            case .TOO_MANY_ATTEMPTS_TRY_LATER:
                ("Слишком много попыток", "Повторите позже")
            case .TOKEN_EXPIRED:
                ("Ваша сессия закончилась", nil)
            case .USER_DISABLED:
                ("Пользователь не найден", nil)
            case .USER_NOT_FOUND:
                ("Пользователь не найден", nil)
            case .INVALID_REFRESH_TOKEN:
                ("Ваша сессия закончилась", nil)
            case .EMAIL_NOT_FOUND:
                ("Email не найден", nil)
            case .INVALID_PASSWORD:
                ("Неверный пароль", nil)
            case .userWasNotFound:
                ("Пользователь не найден", nil)
            case .userIsOwnerOfCompany:
                ("Пользователь владелец организации", nil)
            case .invalidPictureId:
                ("invalidPictureId", nil)
            case .fileNotFound:
                ("invalidPictureId", nil)
            case .userIsNotInYourCompany:
                ("Пользователь не в этой организации", nil)
            case .userIsAlreadyAttachedToCompany:
                ("Пользователь уже принадлежит организации", nil)
            case .companyisPrivate:
                ("Организации приватная", nil)
            case .dateShouldBeGreaterStart_date:
                ("Неправильная дата", nil)
            case .dateShouldBeLessMax_date:
                ("Неправильная дата", nil)
            case .since_dateShouldBeLessThanEnd_dateWithDifferenceNotMoreThan31Day:
                ("Неправильная дата", nil)
            case .tourYearDoesNotExist:
                ("Экскурсия не найдена", nil)
            case .tourMonthDoesNotExist:
                ("Экскурсия не найдена", nil)
            case .tourDayDoesNotExist:
                ("Экскурсия не найдена", nil)
            case .tourDoesNotExist:
                ("Экскурсия не найдена", nil)
            case .guideIsNotInTour:
                ("Экскурсовод не в этой экскурсии", nil)
            case .unknown:
                ("Неизвестная ошибка", nil)
            case .noConnection:
                ("Отсутствует интернет соединение", nil)
            }
        }
    }
    
    public struct ResponseWithErrorJsonStruct: Codable {
        let detail:String
    }
    
    public static func parseError(data:Data?)->NetworkError{
        if let errorDecoded = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: data ?? Data()){
            return NetworkError.getError(msg: errorDecoded.detail)
        }
        return NetworkError.unknown
    }
    
    
    
    // MARK: - URLS Base
    
    public class Auth{
        private static let authUrlBase = newDomain + "auth"
        
        public static let signUp = authUrlBase + "/signup"
        public static let login = authUrlBase + "/login"
        public static let logout = authUrlBase + "/logout"
        public static let logoutAllDevices = authUrlBase + "/logout_all_devices"
        public static let refreshUserToken = authUrlBase + "/refresh_user_token"
        public static func checkEmail(email:String) -> String {
            return authUrlBase + "/refresh_user_token?email=\(email)"
        }
        
        public static let getLoggedDevices = authUrlBase + "/logged_in_devices"
        public static let sendVerifyEmail = authUrlBase + "/send_verify_email"
        
        public static func resetPassword(email:String) ->String{
            return authUrlBase + "/reset_password?email=\(email)"
        }
        
        public static let updatepassword = authUrlBase + "/update_password"
        
    }
    
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
        private static func employeeBaseUrl(companyId:String) -> String{
            return "\(Companies.companiesUrlBase)/\(companyId)/employee"
        }
        
        public static func getCurrentCompanyUserAccessLevels(companyId:String) -> String{
            return employeeBaseUrl(companyId: companyId) + "/"
        }
        
        public static func registerToCompany(companyId:String) ->String {
            return employeeBaseUrl(companyId: companyId) + "/"
        }
        
        public static func updateCompanyUserAccessLevels(companyId:String, employeeId:String) -> String{
            return employeeBaseUrl(companyId: companyId) + "/" + employeeId
        }
        
        public static func getCompanyUsers(companyId:String) -> String{
            return employeeBaseUrl(companyId: companyId) + "/all"
        }
        
        public static func getCompanyGuides(companyId:String) -> String{
            return employeeBaseUrl(companyId: companyId) + "/guides"
        }
        
        public static func getUserInfoByTarget(targetId:String, companyId:String) ->String{
            return employeeBaseUrl(companyId: companyId) + "/\(targetId)"
        }
    }
    
    public class Users{
        private static var usersBaseUrl = newDomain + "users"
        
        public static var getUserInfo = usersBaseUrl + "/";
        public static var updateUserInfo = usersBaseUrl + "/";
        
        public static var deleteUser = usersBaseUrl + "/";
        
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
            static let refreshToken = "refresh-token"
        }
        
        public func getHeaders()->HTTPHeaders{
            return HTTPHeaders(headers)
        }
        
        public func addAccessTokenHeader(){
            headers[Keys.accessToken] = keyChainService.getAcessToken() ?? ""
        }
        
        public func addRefreshToken(){
            headers[Keys.refreshToken] = keyChainService.getRefreshToken() ?? ""
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
    
}
