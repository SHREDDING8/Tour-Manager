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
        
    func addNewTour(tour:ExcrusionModel) async throws -> Bool
        
    func updateTour(tour:ExcrusionModel, oldDate:Date) async throws -> Bool
    
    func deleteTour(date:String, tourId:String) async throws -> Bool
    
    func getTour(tourDate:String, tourId:String, guideOnly:Bool) async throws -> ResponseGetExcursion
    
    func getDateTourList(date:String, guideOnly:Bool) async throws -> [ResponseGetExcursion]
                
    func setGuideTourStatus(tourDate:String, tourId:String, guideStatus:Status) async throws ->Bool
    
    
    func getTourDates(startDate:String, endDate:String, guideOnly:Bool) async throws -> ExcursionsListByRange
}

class ApiManagerExcursions: ApiManagerExcursionsProtocol{
    
    let generalData = NetworkServiceHelper()
    
    let keychainService:KeychainServiceProtocol = KeychainService()
    
    private let domain:String
    private let prefix:String
    
    private let routeGetExcursions:String
    
    private let routeGetExcursionsForGuides:String
    
    private let routeSetGuideTourStatus:String
    
    init(){
        self.domain = generalData.domain
        self.prefix = domain + "tours/"
        
        self.routeGetExcursions = prefix + "get_tour_list"
        
        self.routeGetExcursionsForGuides = prefix + "get_guide_tour_list"
                
        self.routeSetGuideTourStatus = prefix + "set_guide_tour_status"
    }
    
    // MARK: - GetExcursions
    
    func addNewTour(tour:ExcrusionModel) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Tours.addTour(
                companyId: keychainService.getCompanyLocalId() ?? "",
                tourDate: tour.dateAndTime
            )
        )!
        
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
        
        let jsonData = SendAddTour(
            tourName: tour.tourTitle,
            tourRoute: tour.route,
            tourNotes: tour.notes,
            tourNotesVisible: tour.guideCanSeeNotes,
            tourNumberOfPeople: tour.numberOfPeople,
            tourTimeStart: tour.dateAndTime.timeToString(),
            customerCompanyName: tour.customerCompanyName,
            customerGuideName: tour.customerGuideName,
            customerGuideContact: tour.companyGuidePhone,
            isPaid: tour.isPaid,
            paymentMethod: tour.paymentMethod,
            paymentAmount: tour.paymentAmount,
            guides: guides
        )
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response { response in
                
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
    
    func updateTour(tour:ExcrusionModel, oldDate:Date) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Tours.updateTour(
                companyId: keychainService.getCompanyLocalId() ?? "",
                tourDate: oldDate,
                new_tour_date: tour.dateAndTime,
                tourId: tour.tourId
            )
        )!
        
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
        
        let jsonData = SendAddTour(
            tourName: tour.tourTitle,
            tourRoute: tour.route,
            tourNotes: tour.notes,
            tourNotesVisible: tour.guideCanSeeNotes,
            tourNumberOfPeople: tour.numberOfPeople,
            tourTimeStart: tour.dateAndTime.timeToString(),
            customerCompanyName: tour.customerCompanyName,
            customerGuideName: tour.customerGuideName,
            customerGuideContact: tour.companyGuidePhone,
            isPaid: tour.isPaid,
            paymentMethod: tour.paymentMethod,
            paymentAmount: tour.paymentAmount,
            guides: guides
        )
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .put, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response { response in
                
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
    func deleteTour(date:String, tourId:String) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        // TODO:- реализовать в view GetTour
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Tours.deleteTour(
                companyId: keychainService.getCompanyLocalId() ?? "",
                tourDate: date,
                tourId: tourId
            )
        )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .delete,headers: headers.getHeaders()).response { response in
                
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
    
    
    func getTour(tourDate:String, tourId:String, guideOnly:Bool) async throws -> ResponseGetExcursion{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Tours.getTour(
                companyId: keychainService.getCompanyLocalId() ?? "",
                tourDate: tourDate,
                tourId: tourId,
                guideOnly: guideOnly
            )
        )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:ResponseGetExcursion = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        
                        let tour = try! JSONDecoder().decode(ResponseGetExcursion.self, from: response.data!)
                        
                        continuation.resume(returning: tour)
                        
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
    
    
    func getDateTourList(date:String, guideOnly:Bool) async throws -> [ResponseGetExcursion]{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Tours.getDateTourList(
                companyId: keychainService.getCompanyLocalId() ?? "",
                tourDate: date,
                guideOnly: guideOnly
            )
        )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:[ResponseGetExcursion] = try await withCheckedThrowingContinuation { continuaiton in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(_):
                    print(date)
                    if response.response?.statusCode == 400{
                        
                        let error = self.checkError(data: response.data ?? Data())
                        continuaiton.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        typealias excursionsJsonStruct = [ResponseGetExcursion]
                        
                        if let excursions = try? JSONDecoder().decode(excursionsJsonStruct.self, from: response.data!){
                            continuaiton.resume(returning: excursions)
                        }else{
                            continuaiton.resume(throwing: customErrorExcursion.unknown)
                        }
                        
                        
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
    
    
    // MARK: - getTourDates
    public func getTourDates(startDate:String, endDate:String, guideOnly:Bool) async throws -> ExcursionsListByRange{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
                
        let url = URL(
            string: NetworkServiceHelper.Tours.getTourDates(
                companyId: keychainService.getCompanyLocalId() ?? "",
                guideOnly: guideOnly,
                startDate: startDate,
                endDate: endDate
            )
        )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
        
        let result:ExcursionsListByRange = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url,method: .get, headers: headers.getHeaders()).response { response in
                                
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

    
    func setGuideTourStatus(tourDate:String, tourId:String, guideStatus:Status) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw customErrorUserData.unknowmError
        }
        
        let url = URL(
            string: NetworkServiceHelper.Tours.setTourGuideStatus(
                companyId: keychainService.getCompanyLocalId() ?? "",
                tourDate: tourDate,
                tourId: tourId
            )
        )!
        
        let headers = NetworkServiceHelper.Headers()
        headers.addAccessTokenHeader()
                
        
        let jsonData = SendSetGuideStatus(
            guide_status: guideStatus.rawValue
        )
        
        let result:Bool = try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: jsonData, encoder: .json, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 400{
                        let error = self.checkError(data: response.data ?? Data())
                        continuation.resume(throwing: error)
                        
                    }else if response.response?.statusCode == 200{
                        continuation.resume(returning: true)
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




