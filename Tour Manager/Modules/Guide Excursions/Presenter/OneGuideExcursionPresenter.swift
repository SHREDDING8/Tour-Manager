//
//  OneGuideExcursionPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation

protocol OneGuideExcursionViewProtocol:AnyObject{
    func updateGuideStatus(guideStatus: Status)
}

protocol OneGuideExcursionPresenterProtocol:AnyObject{
    init(view:OneGuideExcursionViewProtocol, tour:ExcrusionModel)
    
    var tour:ExcrusionModel! { get set }
    
    func setGuideTourStatus(guideStatus: Status)
    
    func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void)
}

class OneGuideExcursionPresenter:OneGuideExcursionPresenterProtocol{
    weak var view:OneGuideExcursionViewProtocol?
    
    var tour:ExcrusionModel!
    
    let apiManagerExcursions = ApiManagerExcursions()
    let keychain = KeychainService()
    let apiUserData = ApiManagerUserData()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    
    required init(view:OneGuideExcursionViewProtocol, tour:ExcrusionModel) {
        self.view = view
        self.tour = tour
    }
    
    func setGuideTourStatus(guideStatus: Status){
        Task{
            do{
                if try await toursNetworkService.setGuideTourStatus(tourDate: tour.dateAndTime.birthdayToString(), tourId: tour.tourId, guideStatus: guideStatus){
                    DispatchQueue.main.async {
                        self.view?.updateGuideStatus(guideStatus:guideStatus)
                    }
                }
            }catch{
                
            }
            
        }
        
    }
        
    public func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void){
        
        self.apiUserData.downloadProfilePhoto(token: keychain.getAcessToken() ?? "", localId: localId) { isDownloaded, data, error in
            
            completion(data,error)
        }
    }
}
