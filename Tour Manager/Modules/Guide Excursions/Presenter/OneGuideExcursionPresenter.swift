//
//  OneGuideExcursionPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation

protocol OneGuideExcursionViewProtocol:AnyObject{
    
}

protocol OneGuideExcursionPresenterProtocol:AnyObject{
    init(view:OneGuideExcursionViewProtocol)
    
    func setGuideTourStatus(tourDate: String, tourId: String, guideStatus: Status, completion: @escaping (Bool, customErrorExcursion?)->Void )
    
    func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void)
}

class OneGuideExcursionPresenter:OneGuideExcursionPresenterProtocol{
    weak var view:OneGuideExcursionViewProtocol?
    
    let apiManagerExcursions = ApiManagerExcursions()
    let keychain = KeychainService()
    let apiUserData = ApiManagerUserData()
    
    required init(view:OneGuideExcursionViewProtocol) {
        self.view = view
    }
    
    public func setGuideTourStatus(tourDate: String, tourId: String, guideStatus: Status, completion: @escaping (Bool, customErrorExcursion?)->Void ){
        apiManagerExcursions.setGuideTourStatus(token: keychain.getAcessToken() ?? "", uid: keychain.getAcessToken() ?? "", companyId: keychain.getCompanyLocalId() ?? "", tourDate: tourDate, tourId: tourId, guideStatus: guideStatus) { isSetted, error in
            completion(isSetted,error)
        }
    }
    
    public func downloadProfilePhoto(localId:String, completion: @escaping (Data?,customErrorUserData?)->Void){
        
        self.apiUserData.downloadProfilePhoto(token: keychain.getAcessToken() ?? "", localId: localId) { isDownloaded, data, error in
            
            completion(data,error)
        }
    }
}
