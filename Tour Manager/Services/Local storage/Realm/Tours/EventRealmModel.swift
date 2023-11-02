//
//  EventsRealmModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 16.10.2023.
//

import Foundation
import RealmSwift

class EventRealmModel:Object{
    @Persisted(primaryKey: true) var tourDate: String
    
    @Persisted var accept: Bool
    @Persisted var waiting: Bool
    @Persisted var cancel: Bool
    @Persisted var emptyGuide:Bool
    
    convenience init(tourDate: String, accept: Bool, waiting: Bool, cancel: Bool, emptyGuide:Bool) {
        self.init()
        self.tourDate = tourDate
        self.accept = accept
        self.waiting = waiting
        self.cancel = cancel
        self.emptyGuide = emptyGuide
    }
}
