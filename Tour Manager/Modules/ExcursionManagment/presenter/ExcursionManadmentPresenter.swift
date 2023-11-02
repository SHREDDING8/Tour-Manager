//
//  ExcursionManadmentPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.10.2023.
//

import Foundation
import UIKit
import RealmSwift

protocol ExcursionManadmentViewProtocol:AnyObject{
    func updateTours()
    func updateEvents()
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
        self.view?.updateTours()
        
        print("toursRealmService.getTours")
        if let tours = toursRealmService.getTours(dateString: dateString){
            var toursModel:[ExcrusionModel] = []
            for tour in tours.tours{
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
            print("toursRealmService.updateTours")
            self.view?.updateTours()
            
        }
    }
    
    private func loadToursFromServer(date:Date){
        Task{
            do{
                let toursJson = try await toursNetworkService.GetExcursions(date: date.birthdayToString())
                
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
                
                DispatchQueue.main.async {
                    self.toursRealmService.setTours(dateExcursions: realm)
                    self.loadToursFromRealm(date: date)
                }
                
            }catch{
                
            }
        }
    }
    
    func deleteTour(date:Date, excursionId:String){
        Task{
            do{
                let result = try await toursNetworkService.deleteExcursion(date: date.birthdayToString(), excursionId: excursionId)
                
                if result{
                    DispatchQueue.main.async {
                        self.toursRealmService.deleteTour(tourId: excursionId)
                        self.loadToursFromRealm(date: date)
                    }
                }
                
            } catch{
                
            }
        }
        
    }
    
    func getEvent(tourDate:Date) -> EventRealmModel?{
        toursRealmService.getEvent(tourDate: tourDate.birthdayToString())
    }
    
    func getExcursionsListByRangeFromServer(startDate:Date, endDate:Date){
        view?.updateEvents()
        Task{
            do{
                let results = try await toursNetworkService.getExcursionsListByRange(startDate: startDate.birthdayToString(), endDate: endDate.birthdayToString())
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
                    print("addEvents")
                    self.toursRealmService.addEvents(events: eventsRealm)
                    view?.updateEvents()
                    
                }
                
            } catch{
                print("catch")
            }
        }
        
    }
    
}
