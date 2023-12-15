//
//  ApiManagerAutoFill.swift
//  Tour Manager
//
//  Created by SHREDDING on 17.06.2023.
//

import Foundation
import Alamofire


class ApiManagerAutoFill{
    
    let generalData = NetworkServiceHelper()
    
//    
//    public func getAutofill(token:String, companyId:String, autoFillKey:AutofillKeys, completion: @escaping (Bool,[String]?,customErrorAutofill?)->Void ){
//        
////        generalData.requestWithCheckRefresh { newToken in
////            let requestToken = newToken == nil ? token : newToken!
////            
////            let url = URL(string: self.routeGetAutofill)!
////            
////            let jsonData = SendGetAutofill(token: requestToken, company_id: companyId, autofill_key: autoFillKey.rawValue)
////            
////            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
////                
////                switch response.result {
////                case .success(_):
////                    if response.response?.statusCode == 400{
////                        let error = self.checkError(data: response.data ?? Data())
////                        completion(false, nil, error)
////                        return
////                    } else if response.response?.statusCode == 200{
////                        let autofillValues = try! JSONDecoder().decode(ResponseGetAutofill.self, from: response.data!)
////                        completion(true, autofillValues.values, nil)
////                    }else{
////                        completion(false, nil, .unknowmError)
////                    }
////                case .failure(_):
////                    completion(false, nil, .notConnected)
////                }
////                
////                
////            }
////        }
//    }
//    
//    public func addAutofill(token:String, companyId:String, autoFillKey:AutofillKeys, autofillValue:String, completion: @escaping (Bool,customErrorAutofill?)->Void ){
//        
////        generalData.requestWithCheckRefresh { newToken in
////            let requestToken = newToken == nil ? token : newToken!
////            
////            let url = URL(string: self.routeAddAutofill)!
////            
////            let jsonData = SendAddAutofill(token: requestToken, company_id: companyId, autofill_key: autoFillKey.rawValue,autofill_value: autofillValue)
////            
////            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
////                
////                switch response.result {
////                case .success(_):
////                    if response.response?.statusCode == 400{
////                        let error = self.checkError(data: response.data ?? Data())
////                        completion(false, error)
////                        return
////                    } else if response.response?.statusCode == 200{
////                        completion(true, nil)
////                    }else{
////                        completion(false, .unknowmError)
////                    }
////                case .failure(_):
////                    completion(false, .notConnected)
////                }
////            }
////        }
//    }
//    
//    
//    public func deleteAutofill(token:String, companyId:String, autoFillKey:AutofillKeys, autofillValue:String, completion: @escaping (Bool,customErrorAutofill?)->Void ){
//        
////        generalData.requestWithCheckRefresh { newToken in
////            let requestToken = newToken == nil ? token : newToken!
////            
////            let url = URL(string: self.routeDeleteAutofill)!
////            
////            let jsonData = SendAddAutofill(token: requestToken, company_id: companyId, autofill_key: autoFillKey.rawValue,autofill_value: autofillValue)
////            
////            AF.request(url, method: .post, parameters: jsonData, encoder: .json).response { response in
////                
////                switch response.result {
////                case .success(_):
////                    if response.response?.statusCode == 400{
////                        let error = self.checkError(data: response.data ?? Data())
////                        completion(false, error)
////                        return
////                        
////                    } else if response.response?.statusCode == 200{
////                        completion(true, nil)
////                    }else{
////                        completion(false, .unknowmError)
////                    }
////                case .failure(_):
////                    completion(false, .notConnected)
////                }
////            }
////        }
//    }
}
