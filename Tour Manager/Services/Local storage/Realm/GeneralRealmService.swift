//
//  GeneralRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 24.09.2023.
//

import Foundation
import RealmSwift

final class GeneralRealmService{
    let realm = try! Realm()
    
    func deleteAll(){
        try! realm.write({
            realm.deleteAll()
        })
    }
}
