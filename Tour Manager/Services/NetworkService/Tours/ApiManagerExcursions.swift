//
//  ApiManagerExcursions.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation
import Alamofire

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
            throw NetworkServiceHelper.NetworkError.unknown
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
    
    func updateTour(tour:ExcrusionModel, oldDate:Date) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
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
    
    
    // MARK: - DeleteExcursion
    func deleteTour(date:String, tourId:String) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
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
    
    
    func getTour(tourDate:String, tourId:String, guideOnly:Bool) async throws -> ResponseGetExcursion{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
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
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        if let tour = try? JSONDecoder().decode(ResponseGetExcursion.self, from: success ?? Data()){
                            continuation.resume(returning: tour)
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
    
    
    func getDateTourList(date:String, guideOnly:Bool) async throws -> [ResponseGetExcursion]{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
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
        
        let result:[ResponseGetExcursion] = try await withCheckedThrowingContinuation { continuation in
            
            AF.request(url, method: .get, headers: headers.getHeaders()).response { response in
                
                switch response.result {
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        typealias excursionsJsonStruct = [ResponseGetExcursion]
                        
                        if let excursions = try? JSONDecoder().decode(excursionsJsonStruct.self, from: success ?? Data()){
                            continuation.resume(returning: excursions)
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
    
    
    // MARK: - getTourDates
    public func getTourDates(startDate:String, endDate:String, guideOnly:Bool) async throws -> ExcursionsListByRange{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
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
                case .success(let success):
                    
                    switch response.response?.statusCode{
                    case 500:
                        continuation.resume(throwing: NetworkServiceHelper.NetworkError.internalServerError)
                    case 200:
                        
                        if let response = try? JSONDecoder().decode(ExcursionsListByRange.self, from: success ?? Data()){
                            continuation.resume(returning: response)
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

    
    func setGuideTourStatus(tourDate:String, tourId:String, guideStatus:Status) async throws -> Bool{
        let refresh = try await ApiManagerAuth.refreshToken()
        
        if !refresh{
            throw NetworkServiceHelper.NetworkError.unknown
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
    
}




