//
//  ExcursionsRealmServiceForGuide.swift
//  Tour Manager
//
//  Created by SHREDDING on 31.10.2023.
//

import Foundation
import RealmSwift

protocol ExcursionsRealmServiceForGuideProtocol{

    func setToursForGuide(dateExcursions:DatesExcursionForGuide)
    func getToursForGuide(dateString:String) -> DatesExcursionForGuide?
    
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
