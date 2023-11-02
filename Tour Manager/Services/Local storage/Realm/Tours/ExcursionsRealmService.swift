//
//  ExcursionsRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 16.10.2023.
//

import Foundation
import RealmSwift

protocol ExcursionsRealmServiceProtocol{
    func setTours(dateExcursions:DatesExcursion)
    func getTours(dateString:String) -> DatesExcursion?
    func deleteTour(tourId:String)
    
    func getEvent(tourDate:String) -> EventRealmModel?
    func addEvents(events:[EventRealmModel])
    
}

class ExcursionsRealmService:ExcursionsRealmServiceProtocol{
    let realm = try! Realm()
    
    func getTours(dateString:String) -> DatesExcursion?{
        realm.object(ofType: DatesExcursion.self, forPrimaryKey: dateString)
    }
    
    func setTours(dateExcursions:DatesExcursion){
        try! realm.write {
            realm.add(dateExcursions, update: .modified)
        }
    }
    
    func deleteTour(tourId:String){
        if let tour = realm.object(ofType: ExcursionRealmModel.self, forPrimaryKey: tourId){
            try! realm.write({
                realm.delete(tour)
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
    
}
