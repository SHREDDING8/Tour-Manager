//
//  ApiManagerExcursions.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.06.2023.
//

import Foundation
import Alamofire

enum customErrorExcursion{
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

class ApiManagerExcursions{
    
    private static let domain = GeneralData.domain
    private static let prefix = domain + "tours"
    
    private let routeGetExcursions = prefix + "/get_tour_list"
    private let routeAddNewExcursion = prefix + "/add_tour"
    private let routeUpdateExcursion = prefix + "/update_tour"
    private let routeDelteExcursion = prefix + "/delete_tour"
    
    private let routeGetExcursionsForGuides = prefix + "/get_guide_tour_list"
    
    private let routeGetTourListInRange = prefix + "/get_tour_list_in_range"
    
    private let routeGetGuideTourListInRange = prefix + "/get_guide_tour_list_in_range"
    
    private let routeSetGuideTourStatus = prefix + "/set_guide_tour_status"
    
    
    public func GetExcursions(token:String, companyId:String, date:String, completion: @escaping (Bool, [ResponseGetExcursion]?, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeGetExcursions)!
        
        let jsonData = sendForGetExcursion(token: token, company_id: companyId, tour_date: date)
        
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
    
    public func AddNewExcursion(token: String, companyId: String, excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        let url = URL(string: routeAddNewExcursion)!
        
        var guides:[SendGuide] = []
                
        for guide in excursion.selfGuides{
            guides.append(SendGuide(guide_id: guide.guideInfo.getLocalID() ?? "", is_main: guide.isMain, status: guide.status.rawValue))
        }
        
        let jsonData = SendAddNewExcursion(token: token, companyId: companyId, tourName: excursion.excursionName, tourRoute: excursion.route, tourNotes: excursion.additionalInfromation, tourNotesVisible: excursion.guideAccessNotes, tourNumberOfPeople: excursion.numberOfPeople, tourTimeStart: excursion.dateAndTime.timeToString(), tourDate: excursion.dateAndTime.birthdayToString(), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, customerGuideContact: excursion.companyGuidePhone,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount,guides: guides)
        
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true, nil)
                } else{
                    completion(false, .unknown)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
        }
    }
    
    public func updateExcursion(token: String, companyId: String, excursion:Excursion,oldDate:Date, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        let url = URL(string: routeUpdateExcursion)!
        
        var guides:[SendGuide] = []
                
        for guide in excursion.selfGuides{
            guides.append(SendGuide(guide_id: guide.guideInfo.getLocalID() ?? "", is_main: guide.isMain, status: guide.status.rawValue))
        }
        
        
        let jsonData = SendUpdateExcursion(token: token, companyId: companyId, excursionId: excursion.localId ?? "", tourName: excursion.excursionName, tourRoute: excursion.route, tourNotes: excursion.additionalInfromation, tourNotesVisible: excursion.guideAccessNotes, tourNumberOfPeople: excursion.numberOfPeople, tourTimeStart: excursion.dateAndTime.timeToString(), tourDate: excursion.dateAndTime.birthdayToString(), oldDate: oldDate.birthdayToString(), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, customerGuideContact: excursion.companyGuidePhone,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount,guides: guides)
        
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, error)
                    
                } else if response.response?.statusCode == 200{
                    completion(true, nil)
                } else{
                    completion(false, .unknown)
                }
            case .failure(_):
                completion(false, .notConnected)
            }
        }
    }
    
    public func deleteExcursion(token:String, companyId:String, date:String, excursionId:String, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeDelteExcursion)!
        
        let jsonData = sendForDeleteExcursion(token: token, company_id: companyId, tour_date: date, tour_id: excursionId)
        
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
    
    
    public func GetExcursionsForGuides(token:String, companyId:String, date:String, completion: @escaping (Bool, [ResponseGetExcursion]?, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeGetExcursionsForGuides)!
        
        let jsonData = sendForGetExcursion(token: token, company_id: companyId, tour_date: date)
        
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
    
    public func getExcursionsListByRange(token:String, companyId:String, startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListByRange?, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeGetTourListInRange)!
                
//        print("\n\n[getExcursionsListByRange: \(token)]\n\n")
        
        let jsonData = SendGetExcursionsListByRange(token: token, company_id: companyId, tour_date_start: startDate, tour_date_end: endDate)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 400{
                    
                    let error = self.checkError(data: response.data ?? Data())
                    completion(false, nil, error)
                    
                }else if response.response?.statusCode == 200{
                    let response = try! JSONDecoder().decode(ExcursionsListByRange.self, from: response.data!)
                    completion(true, response, nil)
                }else{
                    completion(false, nil, .unknown)
                }
            case .failure(_):
                completion(false, nil, .notConnected)
            }
            
            
            
        }
        
    }
    
    
    public func getExcursionsForGuideListByRange(token:String, companyId:String, startDate:String, endDate:String, completion: @escaping (Bool, ExcursionsListForGuideByRange?, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeGetGuideTourListInRange)!
        
        
//        print("\n\n[getExcursionsForGuideListByRange: \(token)]\n\n")
        
        let jsonData = SendGetExcursionsListByRange(token: token, company_id: companyId, tour_date_start: startDate, tour_date_end: endDate)
        
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
    
    public func setGuideTourStatus(token:String, uid:String, companyId:String, tourDate:String, tourId:String, guideStatus:Status, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeSetGuideTourStatus)!
        
        let jsonData = SendSetGuideStatus(token: token, uid: uid, company_id: companyId, tour_date: tourDate, tour_id: tourId, guide_status: guideStatus.rawValue)
        
        
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




