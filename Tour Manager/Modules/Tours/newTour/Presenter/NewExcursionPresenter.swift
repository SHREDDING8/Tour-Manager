//
//  NewExcursionPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation
import UIKit

protocol NewExcursionViewProtocol:AnyObject{
    func delete(isSuccess:Bool)
    func isAdded(isSuccess:Bool)
    func isUpdated(isSuccess:Bool)
    
    func updateCollectionView()
}

protocol NewExcursionPresenterProtocol:AnyObject{
    init(view:NewExcursionViewProtocol, tour:ExcrusionModel?, date:Date?)
    
    var tour:ExcrusionModel! { get set }
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    
    func isEqualTours()->Bool
    
    func updateExcursion()
    
    func createNewExcursion()
        
    func deleteTour()
    
    func getUserPhotoFromRealm(by index:Int) -> UIImage?
    func getUserPhotoFromServer(by index:Int, completion: @escaping ((UIImage?)->Void) )
        
}

class NewExcursionPresenter:NewExcursionPresenterProtocol{
    weak var view:NewExcursionViewProtocol?
    
    var tour:ExcrusionModel!
    
    var oldTour:ExcrusionModel!
    
    let keychain = KeychainService()
    
    let apiUserData = ApiManagerUserData()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    let toursRealmService:ExcursionsRealmServiceProtocol = ExcursionsRealmService()
    
    let usersRealmService:UsersRealmServiceProtocol = UsersRealmService()
    let usersNetworkSevise:ApiManagerUserDataProtocol = ApiManagerUserData()

    required init(view:NewExcursionViewProtocol, tour:ExcrusionModel?, date:Date?) {
        self.view = view
        if tour != nil{
            self.tour = tour
            oldTour = tour
        }else{
            self.tour = ExcrusionModel(guides: [])
            self.tour?.dateAndTime = date ?? Date.now
        }
        
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    func isEqualTours()->Bool{
        return self.tour == oldTour
    }
    
    public func updateExcursion(){
        Task{
            do{
                if try await toursNetworkService.updateTour(tour: tour, oldDate:oldTour.dateAndTime){
                    DispatchQueue.main.async {
                        self.view?.isUpdated(isSuccess: true)
                    }
                }
            } catch{
                DispatchQueue.main.async {
                    self.view?.isUpdated(isSuccess: false)
                }
                
            }
            
        }
        
    }
    
    public func createNewExcursion(){
        Task{
            do{
                if try await toursNetworkService.addNewTour(tour:self.tour){
                    DispatchQueue.main.async {
                        self.view?.isAdded(isSuccess: true)
                    }
                }
                
            } catch{
                DispatchQueue.main.async {
                    self.view?.isAdded(isSuccess: false)
                }
                
            }
        }
        
    }
    
    func deleteTour(){
        Task{
            do{
                let result = try await toursNetworkService.deleteTour(date: oldTour.dateAndTime.birthdayToString(), tourId: tour.tourId)
                
                if result{
                    DispatchQueue.main.async {
                        self.toursRealmService.deleteTour(tourId: self.tour.tourId)
                        self.view?.delete(isSuccess: true)
                    }
                }
                
            } catch{
                DispatchQueue.main.async {
                    self.view?.delete(isSuccess: false)
                }
            }
        }
    }
        
    
    public func getUserPhotoFromRealm(by index:Int) -> UIImage?{
        
        if let imageData = usersRealmService.getUserInfo(localId: self.tour.guides[index].id)?.image{
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
    public func getUserPhotoFromServer(by index:Int, completion: @escaping ((UIImage?)->Void) ){
        Task{
            do {
                let imageData = try await usersNetworkSevise.downloadProfilePhoto(localId:self.tour.guides[index].id)
                
                DispatchQueue.main.async{
                    let guide = self.tour.guides[index]
                    
                    if self.usersRealmService.getUserInfo(localId: guide.id) == nil{
                        let newUser = UserRealm(localId: guide.id, firstName: guide.firstName, secondName: guide.lastName)
                        self.usersRealmService.setUserInfo(user: newUser)
                    }
                    
                    self.usersRealmService.updateImage(id: self.tour.guides[index].id, image: imageData)
                   completion(UIImage(data: imageData))
                }
                
            } catch{
                
            }
        }
    }
    
    // MARK: - setData
    func setAmount(text:String){
        tour.paymentAmount = text
    }
}
