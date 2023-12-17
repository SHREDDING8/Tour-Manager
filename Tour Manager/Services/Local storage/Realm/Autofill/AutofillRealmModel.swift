//
//  AutofillRealmModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 21.10.2023.
//

import Foundation
import RealmSwift

enum AutofillType:String, PersistableEnum{
    case route
    case customerCompanyName
    case customerGuiedName
    case excursionPaymentMethod
}

final class AutofillRealmModel:Object{
    @Persisted(primaryKey: true) var id:String
    @Persisted var type:AutofillType
    @Persisted var value:String
    
    convenience init(type: AutofillType, value: String) {
        self.init()
        self.type = type
        self.value = value
        self.id = value + type.rawValue
    }
    
}
