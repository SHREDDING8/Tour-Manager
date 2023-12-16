//
//  ExcursionsRealmServiceForGuide.swift
//  Tour Manager
//
//  Created by SHREDDING on 31.10.2023.
//

import Foundation
import RealmSwift
import WidgetKit

protocol ExcursionsRealmServiceForGuideProtocol{

    func setToursForGuide(dateExcursions:DatesExcursionForGuide)
    func getToursForGuide(dateString:String) -> DatesExcursionForGuide?
    func updateTour(tourId:String, tour:ExcursionRealmModelForGuide)
    
    func getEventForGuide(tourDate:String) -> EventRealmModelForGuide?
    func addEventsForGuide(events:[EventRealmModelForGuide])
}

class ExcursionsRealmServiceForGuide:ExcursionsRealmServiceForGuideProtocol{
    let realm = try! Realm()

    func getToursForGuide(dateString:String) -> DatesExcursionForGuide?{
        realm.object(ofType: DatesExcursionForGuide.self, forPrimaryKey: dateString)
    }
    
    func setToursForGuide(dateExcursions:DatesExcursionForGuide){
        try! realm.write {
            realm.add(dateExcursions, update: .modified)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func updateTour(tourId:String, tour:ExcursionRealmModelForGuide){
        if let tour = realm.object(ofType: ExcursionRealmModelForGuide.self, forPrimaryKey: tourId){
            try! realm.write({
                realm.add(tour, update: .modified)
                WidgetCenter.shared.reloadAllTimelines()
            })
        }
    }
    
    
    func getEventForGuide(tourDate:String) -> EventRealmModelForGuide?{
        realm.object(ofType: EventRealmModelForGuide.self, forPrimaryKey: tourDate)
    }
    
    func addEventsForGuide(events:[EventRealmModelForGuide]){
        try! realm.write({
            for event in events{
                realm.add(event, update: .modified)
            }
        })
    }
}
