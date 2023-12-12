//
//  ExcursionManadmentPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation
import UIKit
import RealmSwift

protocol ExcursionManadmentViewProtocol:AnyObject, BaseViewControllerProtocol{
    func updateTours(date:Date)
    func updateEvents(startDate:Date, endDate:Date)
    func tourDeleted()
}

protocol ExcursionManadmentPresenterProtocol:AnyObject{
    init(view:ExcursionManadmentViewProtocol)
    
    var tours:[String:[ExcrusionModel]] { get set }
    
    func isAccessLevel(key:AccessLevelKeys) -> Bool
    
    func getEvent(tourDate:Date) -> EventRealmModel?
    func getExcursionsListByRangeFromServer(startDate:Date, endDate:Date)
    
    func loadTours(date:Date)
    func deleteTour(date:Date, excursionId:String)
}

class ExcursionManadmentPresenter:ExcursionManadmentPresenterProtocol{
    weak var view:ExcursionManadmentViewProtocol?
        
    var tours:[String:[ExcrusionModel]] = [:]
    
    let keychain = KeychainService()
    
    let usersRealmService = UsersRealmService()
    let toursRealmService:ExcursionsRealmServiceProtocol = ExcursionsRealmService()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    
    let userRealmService:UsersRealmServiceProtocol = UsersRealmService()
    
    required init(view:ExcursionManadmentViewProtocol) {
        self.view = view
    }
    
    public func isAccessLevel(key:AccessLevelKeys) -> Bool{
        return usersRealmService.getUserAccessLevel(localId: keychain.getLocalId() ?? "", key)
    }
    
    func loadTours(date:Date){
        DispatchQueue.main.async {
            self.loadToursFromRealm(date: date)
            self.loadToursFromServer(date: date)
        }
    }
    
    private func loadToursFromRealm(date:Date){
        let dateString = date.birthdayToString()
        self.view?.updateTours(date: date)
        
        if let tours = toursRealmService.getTours(dateString: dateString)?.getTours(){
            var toursModel:[ExcrusionModel] = []
            for tour in tours{
                var guides:[ExcrusionModel.Guide] = []
                
                for guide in tour.guides{
                    let guideStatus:ExcrusionModel.GuideStatus = {
                        switch guide.status {
                        case .waiting:
                            return .waiting
                        case .cancel:
                            return .cancel
                        case .accept:
                            return .accept
                        }
                    }()
                    let newGuide = ExcrusionModel.Guide(
                        id: guide.id, firstName: guide.firstName,
                        lastName: guide.lastName,
                        isMain: guide.isMain,
                        status: guideStatus)
                    
                    guides.append(newGuide)
                }
                
                
                let newTourModel = ExcrusionModel(
                    tourId: tour.tourId,
                    tourTitle: tour.tourTitle,
                    route: tour.route,
                    notes: tour.notes,
                    guideCanSeeNotes: tour.guideCanSeeNotes,
                    dateAndTime: tour.dateAndTime,
                    numberOfPeople: tour.numberOfPeople,
                    customerCompanyName: tour.customerCompanyName,
                    customerGuideName: tour.customerGuideName,
                    companyGuidePhone: tour.companyGuidePhone,
                    paymentMethod: tour.paymentMethod,
                    paymentAmount: tour.paymentAmount,
                    isPaid: tour.isPaid,
                    guides: guides)
                
                toursModel.append(newTourModel)
            }
            
            self.tours.updateValue(toursModel, forKey: dateString)
            self.view?.updateTours(date: date)
            
        }
    }
    
    private func loadToursFromServer(date:Date){
        view?.setUpdating()
        Task{
            do{
                let toursJson = try await toursNetworkService.getDateTourList(date: date.birthdayToString(), guideOnly: false)
            DispatchQueue.main.async {
                let realmTours:List<ExcursionRealmModel> = List<ExcursionRealmModel>()
                for tourJson in toursJson{
                    let guides: List<OneGuideRealmModel> = List<OneGuideRealmModel>()
                    
                    for tourGuide in tourJson.tourGuides {
                        let guide = OneGuideRealmModel(
                            id: tourGuide.guideID,
                            firstName: tourGuide.guideFirstName ?? "",
                            lastName: tourGuide.guideLastName ?? "",
                            image: nil,
                            isMain: tourGuide.isMain,
                            status: .init(rawValue: tourGuide.status) ?? .waiting
                        )
                        guides.append(guide)
                        
                        self.userRealmService.ovverideImages(userId: tourGuide.guideID, pictureIds: tourGuide.profilePictures)
                    }
                    
                    
                    let newRealmTour = ExcursionRealmModel(
                        tourId: tourJson.tourId,
                        tourTitle: tourJson.tourName,
                        route: tourJson.tourRoute,
                        notes: tourJson.tourNotes,
                        guideCanSeeNotes: tourJson.tourNotesVisible,
                        dateAndTime: Date.dateAndTimeToDate(dateString: date.birthdayToString(), timeString: tourJson.tourTimeStart),
                        numberOfPeople: tourJson.tourNumberOfPeople,
                        customerCompanyName: tourJson.customerCompanyName,
                        customerGuideName: tourJson.customerGuideName,
                        companyGuidePhone: tourJson.customerGuideContact,
                        paymentMethod: tourJson.paymentMethod,
                        paymentAmount: tourJson.paymentAmount,
                        isPaid: tourJson.isPaid,
                        guides: guides
                    )
                    
                    realmTours.append(newRealmTour)
                }
                
                let realm = DatesExcursion(dateString: date.birthdayToString(), tours: realmTours)
                
                    self.toursRealmService.setTours(dateExcursions: realm)
                    self.loadToursFromRealm(date: date)
                }
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                        view?.showError(error: err)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopUpdating()
            }
            
        }
    }
    
    func deleteTour(date:Date, excursionId:String){
        view?.setSaving()
        Task{
            do{
                let result = try await toursNetworkService.deleteTour(date: date.birthdayToString(), tourId: excursionId)
                
                if result{
                    DispatchQueue.main.async {
                        self.toursRealmService.deleteTour(tourId: excursionId)
                        self.loadToursFromRealm(date: date)
                        self.view?.tourDeleted()
                    }
                }
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
            
            DispatchQueue.main.async {
                self.view?.stopSaving()
            }
        }
        
    }
    
    func getEvent(tourDate:Date) -> EventRealmModel?{
        toursRealmService.getEvent(tourDate: tourDate.birthdayToString())
    }
    
    func getExcursionsListByRangeFromServer(startDate:Date, endDate:Date){
        Task{
            do{
                let results = try await toursNetworkService.getTourDates(startDate: startDate.birthdayToString(), endDate: endDate.birthdayToString(),guideOnly: false)
                var eventsRealm:[EventRealmModel] = []
                for result in results{
                    let eventRealm = EventRealmModel(
                        tourDate: result.tourDate,
                        accept: result.accept,
                        waiting: result.waiting,
                        cancel: result.cancel,
                        emptyGuide: result.emptyGuide
                    )
                    eventsRealm.append(eventRealm)
                }
                
                DispatchQueue.main.sync {
                    
                    self.toursRealmService.addEvents(events: eventsRealm)
                    view?.updateEvents(startDate: startDate, endDate: endDate)
                    
                }
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
            
        }
        
    }
    
}
