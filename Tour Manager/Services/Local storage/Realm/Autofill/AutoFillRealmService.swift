//
//  AutoFillRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 21.10.2023.
//

import Foundation
import RealmSwift

protocol AutoFillRealmServiceProtocol{
    func getAllValues(type:AutofillType) -> Results<AutofillRealmModel>
    func delete(object:AutofillRealmModel)
    func saveValue(type:AutofillType, value:String)
}

class AutoFillRealmService:AutoFillRealmServiceProtocol{
    
    let realm = try! Realm()
    
    func getAllValues(type: AutofillType) -> Results<AutofillRealmModel> {
        realm.objects(AutofillRealmModel.self).where { query in
            query.type == type
        }
    }
    
    func delete(object:AutofillRealmModel){
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func saveValue(type:AutofillType, value:String){
        let newObject = AutofillRealmModel(type: type, value: value)
        
        try! realm.write({
            realm.add(newObject, update: .modified)
        })
    }
    
}
