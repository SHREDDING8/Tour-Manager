//
//  ExcursionsRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 16.10.2023.
//

import Foundation
import RealmSwift
import WidgetKit
import UIKit

protocol ExcursionsRealmServiceProtocol{
    func setTours(dateExcursions:DatesExcursion)
    func getTours(dateString:String) -> DatesExcursion?
    func deleteTour(tourId:String)
    func updateTour(tourId:String, tour:ExcursionRealmModel)
    
    func getEvent(tourDate:String) -> EventRealmModel?
    func addEvents(events:[EventRealmModel])
    func deleteEventsByRange(startDate:Date, endDate:Date)
    
}

final class ExcursionsRealmService:ExcursionsRealmServiceProtocol{
    private var realm: Realm {
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Shredding.Tour-Manager")
            let realmURL = container?.appendingPathComponent("default.realm")
            let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
            return try! Realm(configuration: config)
        }
    
    func getTours(dateString:String) -> DatesExcursion?{
        realm.object(ofType: DatesExcursion.self, forPrimaryKey: dateString)
    }
    
    func setTours(dateExcursions:DatesExcursion){
        try! realm.write {
            realm.add(dateExcursions, update: .modified)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func deleteTour(tourId:String){
        if let tour = realm.object(ofType: ExcursionRealmModel.self, forPrimaryKey: tourId){
            try! realm.write({
                realm.delete(tour)
                WidgetCenter.shared.reloadAllTimelines()
            })
        }
    }
    
    func updateTour(tourId:String, tour:ExcursionRealmModel){
        if let tour = realm.object(ofType: ExcursionRealmModel.self, forPrimaryKey: tourId){
            try! realm.write({
                realm.add(tour, update: .modified)
                WidgetCenter.shared.reloadAllTimelines()
            })
        }
    }
    
    func getEvent(tourDate:String) -> EventRealmModel?{
        realm.object(ofType: EventRealmModel.self, forPrimaryKey: tourDate)
    }
    
    func addEvents(events:[EventRealmModel]){
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
                if let object = realm.object(ofType: EventRealmModel.self, forPrimaryKey: key){
                    realm.delete(object)
                }
            }
        })
    }
    
}
