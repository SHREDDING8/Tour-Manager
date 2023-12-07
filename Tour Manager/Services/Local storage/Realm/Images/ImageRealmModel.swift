//
//  ImageRealmModel.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.12.2023.
//

import Foundation
import RealmSwift

class ImageRealmModel:Object{
    @Persisted(primaryKey: true) var id:String
    @Persisted var imageData:Data
    
    convenience init(id: String, imageData: Data) {
        self.init()
        self.id = id
        self.imageData = imageData
    }
}
