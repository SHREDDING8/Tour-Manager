//
//  ImagesRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.12.2023.
//

import Foundation
import RealmSwift

protocol ImagesRealmServiceProtocol{
    func setNewImage(id:String, _ imageData:Data)
    func getImage(by id:String) -> Data?
    func deleteImage(by id:String)
}

class ImagesRealmService:ImagesRealmServiceProtocol{
    let realm = try! Realm()
    
    func setNewImage(id:String, _ imageData:Data){
        let imageModel = ImageRealmModel(
            id: id,
            imageData: imageData
        )
        
        try! realm.write({
            realm.add(imageModel)
        })
        
    }
    
    func getImage(by id:String) -> Data?{
        realm.object(ofType: ImageRealmModel.self, forPrimaryKey: id)?.imageData
    }
    
    func deleteImage(by id:String){
        if let image = realm.object(ofType: ImageRealmModel.self, forPrimaryKey: id){
            try! realm.write {
                realm.delete(image)
            }
        }

    }
}
