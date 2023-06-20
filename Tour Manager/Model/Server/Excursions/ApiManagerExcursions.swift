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
    
    
}

class ApiManagerExcursions{
    
    private static let domain = GeneralData.domain
    private static let prefix = domain + "tours"
    
    private let routeGetExcursions = prefix + "/get_tour_list"
    private let routeAddNewExcursion = prefix + "/add_tour"
    private let routeUpdateExcursion = prefix + "/update_tour"
    private let routeDelteExcursion = prefix + "/delete_tour"
    
    private let routeGetExcursionsForGuides = prefix + "get_guide_tour_list"
    
    
    public func GetExcursions(token:String, companyId:String, date:String, completion: @escaping (Bool, [ResponseGetExcursion]?, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeGetExcursions)!
        
        let jsonData = sendForGetExcursion(token: token, company_id: companyId, tour_date: date)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Date does not exist"{
                    completion(false, nil, .dataNotFound)
                } else if error.message == "Token expired"{
                    completion(false, nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, nil, .invalidToken)
                } else if error.message == "Permission denied"{
                    completion(false, nil, .PermissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, nil, .UserIsNotInThisCompany)
                }else if error.message == "Company does not exist"{
                    completion(false, nil, .CompanyDoesNotExist)
                }else {
                    completion(false, nil, .unknown)
                }
                return
                
            }else if response.response?.statusCode == 200{
                typealias excursionsJsonStruct = [ResponseGetExcursion]
                
                let excursions = try! JSONDecoder().decode(excursionsJsonStruct.self, from: response.data!)
                
                completion(true, excursions, nil )
  
            }else{
                completion(false,nil, .unknown)
            }
        }
        
    }
    
    public func AddNewExcursion(token: String, companyId: String, excursion:Excursion, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        let url = URL(string: routeAddNewExcursion)!
        
        var guides:[SendGuide] = []
                
        for guide in excursion.selfGuides{
            guides.append(SendGuide(guide_id: guide.guideInfo.getLocalID() ?? "", is_main: guide.isMain, status: guide.status.rawValue))
        }
        
        let jsonData = SendAddNewExcursion(token: token, companyId: companyId, tourName: excursion.excursionName, tourRoute: excursion.route, tourNotes: excursion.additionalInfromation, tourNumberOfPeople: excursion.numberOfPeople, tourTimeStart: excursion.dateAndTime.timeToString(), tourDate: excursion.dateAndTime.birthdayToString(), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, customerGuideContact: excursion.companyGuidePhone,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount,guides: guides)
        
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired"{
                    completion(false,  .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                } else if error.message == "Permission denied"{
                    completion(false, .PermissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, .UserIsNotInThisCompany)
                }else if error.message == "Company does not exist"{
                    completion(false, .CompanyDoesNotExist)
                }else {
                    completion(false, .unknown)
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            } else{
                completion(false, .unknown)
            }
        }
    }
    
    public func updateExcursion(token: String, companyId: String, excursion:Excursion,oldDate:Date, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        let url = URL(string: routeUpdateExcursion)!
        
        var guides:[SendGuide] = []
                
        for guide in excursion.selfGuides{
            guides.append(SendGuide(guide_id: guide.guideInfo.getLocalID() ?? "", is_main: guide.isMain, status: guide.status.rawValue))
        }
        
        
        let jsonData = SendUpdateExcursion(token: token, companyId: companyId, excursionId: excursion.localId ?? "", tourName: excursion.excursionName, tourRoute: excursion.route, tourNotes: excursion.additionalInfromation, tourNumberOfPeople: excursion.numberOfPeople, tourTimeStart: excursion.dateAndTime.timeToString(), tourDate: excursion.dateAndTime.birthdayToString(), oldDate: oldDate.birthdayToString(), customerCompanyName: excursion.customerCompanyName, customerGuideName: excursion.customerGuideName, customerGuideContact: excursion.companyGuidePhone,isPaid: excursion.isPaid, paymentMethod: excursion.paymentMethod, paymentAmount: excursion.paymentAmount,guides: guides)
        
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Token expired"{
                    completion(false,  .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                } else if error.message == "Permission denied"{
                    completion(false, .PermissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, .UserIsNotInThisCompany)
                }else if error.message == "Company does not exist"{
                    completion(false, .CompanyDoesNotExist)
                }else if error.message == "Tour does not exist"{
                    completion(false, .TourDoesNotExist)
                }else {
                    completion(false, .unknown)
                }
                return
            } else if response.response?.statusCode == 200{
                completion(true, nil)
            } else{
                completion(false, .unknown)
            }
        }
    }
    
    public func deleteExcursion(token:String, companyId:String, date:String, excursionId:String, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeDelteExcursion)!
        
        let jsonData = sendForDeleteExcursion(token: token, company_id: companyId, tour_date: date, tour_id: excursionId)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            
            if response.response?.statusCode == 400{
                
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Tour does not exist"{
                    completion(false, .dataNotFound)
                } else if error.message == "Token expired"{
                    completion(false, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, .invalidToken)
                } else if error.message == "Permission denied"{
                    completion(false, .PermissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, .UserIsNotInThisCompany)
                }else if error.message == "Company does not exist"{
                    completion(false, .CompanyDoesNotExist)
                }else {
                    completion(false, .unknown)
                }
                return
                
            }else if response.response?.statusCode == 200{
                
                
                completion(true, nil )
  
            }else{
                completion(false, .unknown)
            }
        }
    }
    
    
    public func GetExcursionsForGuides(token:String, companyId:String, date:String, completion: @escaping (Bool, [ResponseGetExcursion]?, customErrorExcursion?)->Void ){
        
        let url = URL(string: routeGetExcursionsForGuides)!
        
        let jsonData = sendForGetExcursion(token: token, company_id: companyId, tour_date: date)
        
        AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
            if response.response?.statusCode == 400{
                
                let error = try! JSONDecoder().decode(ResponseWithErrorJsonStruct.self, from: response.data!)
                
                if error.message == "Date does not exist"{
                    completion(false, nil, .dataNotFound)
                } else if error.message == "Token expired"{
                    completion(false, nil, .tokenExpired)
                } else if error.message == "Invalid Firebase ID token"{
                    completion(false, nil, .invalidToken)
                } else if error.message == "Permission denied"{
                    completion(false, nil, .PermissionDenied)
                }else if error.message == "Current user is not in this company"{
                    completion(false, nil, .UserIsNotInThisCompany)
                }else if error.message == "Company does not exist"{
                    completion(false, nil, .CompanyDoesNotExist)
                }else {
                    completion(false, nil, .unknown)
                }
                return
                
            }else if response.response?.statusCode == 200{
                typealias excursionsJsonStruct = [ResponseGetExcursion]
                
                let excursions = try! JSONDecoder().decode(excursionsJsonStruct.self, from: response.data!)
                
                completion(true, excursions, nil )

            }else{
                completion(false,nil, .unknown)
            }
        }
        
    }
    
    
    
}




