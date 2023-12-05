//
//  FullCalendarPresenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.12.2023.
//

import Foundation

protocol FullCalendarViewProtocol:AnyObject{
    func updateEvents(startDate:Date, endDate:Date)
}

protocol FullCalendarPresenterProtocol:AnyObject{
    init(view:FullCalendarViewProtocol, isGuide:Bool)
    
    func getEvent(tourDate:Date) -> EventRealmModel?
    
    func getTourDates(startDate:Date, endDate:Date)
}


class FullCalendarPresenter:FullCalendarPresenterProtocol{

    weak var view:FullCalendarViewProtocol?
    var isGuide:Bool = false
    
    let keychain = KeychainService()
    let toursRealmService:ExcursionsRealmServiceProtocol = ExcursionsRealmService()
    
    let toursNetworkService:ApiManagerExcursionsProtocol = ApiManagerExcursions()
    
    required init(view:FullCalendarViewProtocol, isGuide:Bool) {
        self.view = view
        self.isGuide = isGuide
    }
    
    func getEvent(tourDate:Date) -> EventRealmModel?{
        toursRealmService.getEvent(tourDate: tourDate.birthdayToString())
    }
    
    func getTourDates(startDate:Date, endDate:Date){
        Task{
            do{
                let results = try await toursNetworkService.getTourDates(startDate: startDate.birthdayToString(), endDate: endDate.birthdayToString(), guideOnly: isGuide)
                
                if !isGuide{
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
                }

                
            } catch{
                print("catch")
            }
        }
        
    }
    
    
}
