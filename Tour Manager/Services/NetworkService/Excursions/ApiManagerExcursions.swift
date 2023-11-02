//
//  ApiManagerExcursions.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation
import Alamofire

enum customErrorExcursion:Error{
    case unknown
    
    case dataNotFound
    
    case tokenExpired
    case invalidToken
    
    case PermissionDenied
    
    case UserIsNotInThisCompany
    
    case CompanyDoesNotExist
    
    case TourDoesNotExist
    
    case guideIsNotInTour
    
    case notConnected
    
    public func getValuesForAlert()->AlertFields{
        switch self {
        case .unknown:
            return AlertFields(title: "Произошла неизвестная ошибка на сервере")
        case .dataNotFound:
            return AlertFields(title: "Произошла ошибка", message: "Данные не были найдены")
        case .tokenExpired:
            return  AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .invalidToken:
            return  AlertFields(title: "Произошла ошибка", message: "Ваша сессия закончилась")
        case .PermissionDenied:
            return AlertFields(title: "Произошла ошибка", message: "Недостаточно прав доступа для совершения этого действия")
        case .UserIsNotInThisCompany:
            return AlertFields(title: "Произошла ошибка", message: "Пользователь не числится в этой компании")
        case .CompanyDoesNotExist:
            return AlertFields(title: "Произошла ошибка", message: "Компания является частной или не существует")
        case .TourDoesNotExist:
            return AlertFields(title: "Произошла ошибка", message: "Экскурсия не существует")
        case .guideIsNotInTour:
            return AlertFields(title: "Произошла ошибка", message: "Экскурсовод не находится в данной экскурсии")
        case .notConnected:
            return AlertFields(title: "Нет подключения к серверу")
        }
    }
}

protocol ApiManagerExcursionsProtocol{
    func GetExcursions(date:String) async throws -> [ResponseGetExcursion]
    
    func AddNewExcursion(tour:ExcrusionModel) async throws -> Bool
    
    func updateExcursion(tour:ExcrusionModel, oldDate:Date) async throws -> Bool
    
    func deleteExcursion(date:String, excursionId:String) async throws -> Bool
    
    func getExcursionsListByRange(startDate:String, endDate:String) async throws -> ExcursionsListByRange
    
    func GetExcursionsForGuide(date:String) async throws -> [ResponseGetExcursion]
}

class ApiManagerExcursions: ApiManagerExcursionsProtocol{
    
    let generalData = GeneralData()
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    
    private let domain:String
    private let prefix:String
    
    private let routeGetExcursions:String
    private let routeAddNewExcursion:String
    private let routeUpdateExcursion:String
    private let routeDelteExcursion:String
    
    private let routeGetExcursionsForGuides:String
    
    private let routeGetTourListInRange:String
    
    private let routeGetGuideTourListInRange:String
    
    private let routeSetGuideTourStatus:String
    
    init(){
        self.domain = generalData.domain
        self.prefix = domain + "tours/"
        
        self.routeGetExcursions = prefix + "get_tour_list"
        self.routeAddNewExcursion = prefix + "add_tour"
        self.routeUpdateExcursion = prefix + "update_tour"
        self.routeDelteExcursion = prefix + "delete_tour"
        
        self.routeGetExcursionsForGuides = prefix + "get_guide_tour_list"
        
        self.routeGetTourListInRange = prefix + "get_tour_list_in_range"
        
        self.routeGetGuideTourListInRange = prefix + "get_guide_tour_list_in_range"
        
        self.routeSetGuideTourStatus = prefix + "set_guide_tour_status"
    }
    
    // MARK: - GetExcursions
    func GetExcursions(date:String) async throws -> [ResponseGetExcursion]{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeGetExcursions)!
        let jsonData = sendForGetExcursion(token: keychainService.getAcessToken() ?? "", company_id: keychainService.getCompanyLocalId() ?? "", tour_date: date)
        
        let result:[ResponseGetExcursion] = try await withCheckedThrowingContinuation { continuaiton in
            
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuaiton.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        typealias excursionsJsonStruct = [ResponseGetExcursion]
                        
                        let excursions = try! JSONDecoder().decode(excursionsJsonStruct.self, from: response.data!)
                        
                        continuaiton.resume(returning: excursions)
                        
                    }else{
                        continuaiton.resume(throwing: customErrorExcursion.unknown)
                    }
                case .failure(_):
                    continuaiton.resume(throwing: customErrorExcursion.unknown)
                    
                }
            }
            
        }
        
        return result
    }
    
    
    public func AddNewExcursion(tour:ExcrusionModel) async throws -> Bool{
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeAddNewExcursion)!
        
        var guides:[SendGuide] = []
        
        for guide in tour.guides{
            guides.append(
                SendGuide(
                    guide_id: guide.id,
                    is_main: guide.isMain,
                    status: guide.status.rawValue
                )
            )
        }
        
        let jsonData = SendAddNewExcursion(
            token: keychainService.getAcessToken() ?? "",
            companyId: keychainService.getCompanyLocalId() ?? "",
            tourName: tour.tourTitle,
            tourRoute: tour.route,
            tourNotes: tour.notes,
            tourNotesVisible: tour.guideCanSeeNotes,
            tourNumberOfPeople: tour.numberOfPeople,
            tourTimeStart: tour.dateAndTime.timeToString(),
            tourDate: tour.dateAndTime.birthdayToString(),
            customerCompanyName: tour.customerCompanyName,
            customerGuideName: tour.customerGuideName,
            customerGuideContact: tour.companyGuidePhone,
            isPaid: tour.isPaid,
            paymentMethod: tour.paymentMethod,
            paymentAmount: tour.paymentAmount,
            guides: guides
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                        
                    } else{
                        continuation.resume(throwing: customErrorExcursion.unknown)
                    }
                    
                case .failure(_):
                    continuation.resume(throwing: customErrorExcursion.unknown)
                }
            }
        }
        
        return result
    }
    
    public func updateExcursion(tour:ExcrusionModel, oldDate:Date) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeAddNewExcursion)!
        
        var guides:[SendGuide] = []
        
        for guide in tour.guides{
            guides.append(
                SendGuide(
                    guide_id: guide.id,
                    is_main: guide.isMain,
                    status: guide.status.rawValue
                )
            )
        }
        
        let jsonData = SendUpdateExcursion(
            token: keychainService.getAcessToken() ?? "",
            companyId: keychainService.getCompanyLocalId() ?? "",
            excursionId: tour.tourId ,
            tourName: tour.tourTitle,
            tourRoute: tour.route,
            tourNotes: tour.notes,
            tourNotesVisible: tour.guideCanSeeNotes,
            tourNumberOfPeople: tour.numberOfPeople,
            tourTimeStart: tour.dateAndTime.timeToString(),
            tourDate: tour.dateAndTime.birthdayToString(),
            oldDate: oldDate.birthdayToString(),
            customerCompanyName: tour.customerCompanyName,
            customerGuideName: tour.customerGuideName,
            customerGuideContact: tour.companyGuidePhone,
            isPaid: tour.isPaid,
            paymentMethod: tour.paymentMethod,
            paymentAmount: tour.paymentAmount,
            guides: guides
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    } else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
                    } else{
                        continuation.resume(throwing: customErrorExcursion.unknown)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorExcursion.unknown)
                }
            }
        }
        
        return result
    }
    
    // MARK: - DeleteExcursion
    
    func deleteExcursion(date:String, excursionId:String) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeDelteExcursion)!
        
        let jsonData = sendForDeleteExcursion(token: keychainService.getAcessToken() ?? "", company_id: keychainService.getCompanyLocalId() ?? "", tour_date: date, tour_id: excursionId)
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        
                        continuation.resume(returning: true)
                        
                    }else{
                        continuation.resume(returning: false)
                    }
                case .failure(_):
                    continuation.resume(returning: false)
                }
            }
        }
        return result
    }
    
    func GetExcursionsForGuide(date:String) async throws -> [ResponseGetExcursion]{
        let url = URL(string: self.routeGetExcursionsForGuides)!
        
        
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let jsonData = sendForGetExcursion(token: keychainService.getAcessToken() ?? "", company_id: keychainService.getCompanyLocalId() ?? "", tour_date: date)
        
        let result:[ResponseGetExcursion] = try await withCheckedThrowingContinuation { continuaiton in
            
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuaiton.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        typealias excursionsJsonStruct = [ResponseGetExcursion]
                        
                        let excursions = try! JSONDecoder().decode(excursionsJsonStruct.self, from: response.data!)
                        
                        continuaiton.resume(returning: excursions)
                        
                    }else{
                        continuaiton.resume(throwing: customErrorExcursion.unknown)
                    }
                case .failure(_):
                    continuaiton.resume(throwing: customErrorExcursion.unknown)
                    
                }
            }
            
        }
        
        return result
        
    }
    
    public func GetExcursionsForGuides(token:String, companyId:String, date:String, completion: @escaping (Bool, [ResponseGetExcursion]?, customErrorExcursion?)->Void ){
        
        generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            let url = URL(string: self.routeGetExcursionsForGuides)!
            
            let jsonData = sendForGetExcursion(token: requestToken, company_id: companyId, tour_date: date)
            
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        completion(false, nil, error)
                        
                    }else if response.response?.statusCode == 200{
                        typealias excursionsJsonStruct = [ResponseGetExcursion]
                        
                        let excursions = try! JSONDecoder().decode(excursionsJsonStruct.self, from: response.data!)
                        
                        completion(true, excursions, nil )
                        
                    }else{
                        completion(false,nil, .unknown)
                    }
                case .failure(_):
                    completion(false,nil, .notConnected)
                }
            }
        }
    }
    
    // MARK: - getExcursionsListByRange
    func getExcursionsListByRange(startDate:String, endDate:String) async throws -> ExcursionsListByRange{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(string: self.routeGetTourListInRange)!
        
        let jsonData = SendGetExcursionsListByRange(token: keychainService.getAcessToken() ?? "", company_id: keychainService.getCompanyLocalId() ?? "", tour_date_start: startDate, tour_date_end: endDate)
        
        let result:ExcursionsListByRange = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        let response = try! JSONDecoder().decode(ExcursionsListByRange.self, from: response.data!)
                        continuation.resume(returning: response)
                    }else{
                        continuation.resume(throwing: customErrorExcursion.unknown)
                    }
                case .failure(_):
                    continuation.resume(throwing: customErrorExcursion.unknown)
                }
            }
            
        }
        
        return result
        
    }
    
    public func getExcursionsForGuideListByRange(token:String, companyId:String, startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListForGuideByRange?, customErrorExcursion?)->Void ){
        
        generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            let url = URL(string: self.routeGetGuideTourListInRange)!
            
            
            //        print("\n\n[getExcursionsForGuideListByRange: \(token)]\n\n")
            
            let jsonData = SendGetExcursionsListByRange(token: requestToken, company_id: companyId, tour_date_start: startDate, tour_date_end: endDate)
            
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        completion(false, nil, error)
                    }else if response.response?.statusCode == 200{
                        let response = try! JSONDecoder().decode(ExcursionsListForGuideByRange.self, from: response.data!)
                        completion(true, response, nil)
                    }else{
                        completion(false, nil, .unknown)
                    }
                case .failure(_):
                    completion(false, nil, .notConnected)
                }
            }
        }
    }
    
    public func setGuideTourStatus(token:String, uid:String, companyId:String, tourDate:String, tourId:String, guideStatus:Status, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        generalData.requestWithCheckRefresh { newToken in
            let requestToken = newToken == nil ? token : newToken!
            
            let url = URL(string: self.routeSetGuideTourStatus)!
            
            let jsonData = SendSetGuideStatus(token: requestToken, uid: uid, company_id: companyId, tour_date: tourDate, tour_id: tourId, guide_status: guideStatus.rawValue)
            
            
            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        completion(false, error)
                        
                    }else if response.response?.statusCode == 200{
                        completion(true, nil)
                    }else{
                        completion(false, .unknown)
                    }
                case .failure(_):
                    completion(false, .notConnected)
                }
            }
        }
    }
    
    private func checkError(data:Data)->customErrorExcursion{
        if let error = try? JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: data){
            switch error.message{
            case "Token expired":
                return .tokenExpired
            case "Invalid Firebase ID token":
                return .invalidToken
                
            case "Date does not exist", "Tour does not exist":
                return .dataNotFound
                
            case "Permission denied":
                return .PermissionDenied
                
            case "Current user is not in this company":
                return .UserIsNotInThisCompany
                
            case "Company does not exist":
                return .CompanyDoesNotExist
                
            case "Guide is not in tour":
                return .guideIsNotInTour
                
            default:
                return .unknown
            }
        }
        return .unknown
    }
}




