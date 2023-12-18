//
//  EventRealmModelForGuide.swift
//  Tour Manager
//
//  Created by SHREDDING on 31.10.2023.
//

import Foundation
import RealmSwift

final class EventRealmModelForGuide:Object{
    @Persisted(primaryKey: true) var tourDate: String
    
    @Persisted var accept: Bool
    @Persisted var waiting: Bool
    @Persisted var cancel: Bool
    
    convenience init(tourDate: String, accept: Bool, waiting: Bool, cancel: Bool) {
        self.init()
        self.tourDate = tourDate
        self.accept = accept
        self.waiting = waiting
        self.cancel = cancel
    }
}
