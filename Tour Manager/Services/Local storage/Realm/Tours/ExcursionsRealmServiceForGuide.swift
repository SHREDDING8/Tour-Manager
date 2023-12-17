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
    func deleteEventsByRange(startDate:Date, endDate:Date)
}

final class ExcursionsRealmServiceForGuide:ExcursionsRealmServiceForGuideProtocol{
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
    
    func deleteEventsByRange(startDate:Date, endDate:Date){
        
        let keys:[String] = {
            var res:[String] = []
            var date = startDate
            res.append(date.birthdayToString())
            
            while date.birthdayToString() != endDate.birthdayToString(){
                date =  Calendar.current.date(byAdding: .day, value: 1, to: date)!
                res.append(date.birthdayToString())
            }
            
            return res
        }()
        
        try! realm.write({
            for key in keys{
                if let object = realm.object(ofType: EventRealmModelForGuide.self, forPrimaryKey: key){
                    realm.delete(object)
                }
            }
        })
    }
}
