//
//  GuideExcursionsPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.10.2023.
//

import Foundation
import RealmSwift

protocol ExcursionsGuideCalendarViewProtocol:AnyObject, BaseViewControllerProtocol{
    func updateTours(date:Date)
    func endRefreshing(date:Date)
    func updateEvents(startDate:Date, endDate:Date)
}

protocol ExcursionsGuideCalendarPresenterProtocol:AnyObject{
    init(view:ExcursionsGuideCalendarViewProtocol)
        
    var tours:[String:[ExcrusionModel]] { get set }
    
    func loadTours(date:Date)
    func loadToursFromServer(date:Date)
    
    func getExcursionsListByRangeFromServer(startDate:Date, endDate:Date)
    func getEvent(tourDate:Date) -> EventRealmModelForGuide?
    
    }

final class ExcursionsGuideCalendarPresenter:ExcursionsGuideCalendarPresenterProtocol{
    weak var view:ExcursionsGuideCalendarViewProtocol?
        
    var tours:[String:[ExcrusionModel]] = [:]
    
    let keychain = KeychainService()
    let apiManagerExcursions = ApiManagerExcursions()
    
    let toursRealmService:ExcursionsRealmServiceForGuideProtocol = ExcursionsRealmServiceForGuide()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    
    let userRealmService:UsersRealmServiceProtocol = UsersRealmService()
    
    required init(view:ExcursionsGuideCalendarViewProtocol) {
        self.view = view
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
        
        if let tours = toursRealmService.getToursForGuide(dateString: dateString)?.getTours(){
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
    
    public func loadToursFromServer(date:Date){
        view?.setUpdating()
        Task{
            do{
                let toursJson = try await toursNetworkService.getDateTourList(date: date.birthdayToString(), guideOnly: true)
                
                DispatchQueue.main.async {
                    let realmTours:List<ExcursionRealmModelForGuide> = List<ExcursionRealmModelForGuide>()
                    for tourJson in toursJson{
                        let guides: List<OneGuideRealmModelForGuide> = List<OneGuideRealmModelForGuide>()
                        
                        for tourGuide in tourJson.tourGuides {
                            let guide = OneGuideRealmModelForGuide(
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
                        
                        
                        let newRealmTour = ExcursionRealmModelForGuide(
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
                    
                    let realm = DatesExcursionForGuide(dateString: date.birthdayToString(), tours: realmTours)
                    
                    self.toursRealmService.setToursForGuide(dateExcursions: realm)
                    self.loadToursFromRealm(date: date)
                }
                
            }catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
                
            }
            
            DispatchQueue.main.async {
                self.view?.endRefreshing(date: date)
                self.view?.stopUpdating()
            }
        }
    }
    
    func getExcursionsListByRangeFromServer(startDate:Date, endDate:Date){
        view?.updateEvents(startDate: startDate, endDate: endDate)
        Task{
            do{
                let results = try await toursNetworkService.getTourDates(startDate: startDate.birthdayToString(), endDate: endDate.birthdayToString(), guideOnly: true)
                
                
                DispatchQueue.main.async {
                    self.toursRealmService.deleteEventsByRange(startDate: startDate, endDate: endDate)
                }
                
                var eventsRealm:[EventRealmModelForGuide] = []
                for result in results{
                    let eventRealm = EventRealmModelForGuide(
                        tourDate: result.tourDate,
                        accept: result.accept,
                        waiting: result.waiting,
                        cancel: result.cancel
                    )
                    eventsRealm.append(eventRealm)
                }
                
                DispatchQueue.main.sync {
                    
                    self.toursRealmService.addEventsForGuide(events: eventsRealm)
                    view?.updateEvents(startDate: startDate, endDate: endDate)
                    
                }
                
            } catch let error{
                if let err = error as? NetworkServiceHelper.NetworkError{
                    self.view?.showError(error: err)
                }
            }
        }
        
    }
    
    func getEvent(tourDate:Date) -> EventRealmModelForGuide?{
        toursRealmService.getEventForGuide(tourDate: tourDate.birthdayToString())
    }
}
