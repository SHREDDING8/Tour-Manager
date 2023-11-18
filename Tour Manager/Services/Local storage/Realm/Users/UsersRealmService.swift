//
//  UsersRealmService.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.08.2023.
//

import Foundation
import RealmSwift

enum AccessLevelKeys:String{
    case readCompanyEmployee = "readCompanyEmployee"
    case readLocalIdCompany = "readLocalIdCompany"
    case readGeneralCompanyInformation = "readGeneralCompanyInformation"
    case writeGeneralCompanyInformation = "writeGeneralCompanyInformation"
    case canChangeAccessLevel = "canChangeAccessLevel"
    case isOwner = "isOwner"
    case canReadTourList = "canReadTourList"
    case canWriteTourList = "canWriteTourList"
    case isGuide = "isGuide"
    
}


protocol UsersRealmServiceProtocol{
    
    func setUserInfo(user:UserRealm)
    func getUserInfo(localId:String) -> UserRealm?
    func getAllUsers() -> Results<UserRealm>
    func getUserAccessLevel(localId:String, _ key:AccessLevelKeys) -> Bool
    func updateUserAccessLevel(localId:String, accessLevels: UserAccessLevelRealm)
    func updateField(localId:String, updateField: UserDataFields, value:String)
    func updateBirhday(localId:String,date:Date)
    
    func updateImage(id:String, image:Data)
    func deleteImage(id:String)
}

class UsersRealmService:UsersRealmServiceProtocol{
    
    let realm = try! Realm()
    
    func setUserInfo(user: UserRealm) {
        try! realm.write({
            realm.add(user, update: .modified)
        })
    }
    
    func getUserInfo(localId:String) -> UserRealm?{
        realm.object(ofType: UserRealm.self, forPrimaryKey: localId)
    }
    
    func getAllUsers() -> Results<UserRealm>{
        realm.objects(UserRealm.self)
    }
    
    func getUserAccessLevel(localId:String, _ key:AccessLevelKeys) -> Bool{
        if let user = realm.object(ofType: UserRealm.self, forPrimaryKey: localId){
            switch key{
                
            case .readCompanyEmployee:
                return user.accesslLevels?.readCompanyEmployee ?? false
            case .readLocalIdCompany:
                return user.accesslLevels?.readLocalIdCompany ?? false
            case .readGeneralCompanyInformation:
                return user.accesslLevels?.readGeneralCompanyInformation ?? false
            case .writeGeneralCompanyInformation:
                return user.accesslLevels?.writeGeneralCompanyInformation ?? false
            case .canChangeAccessLevel:
                return user.accesslLevels?.canChangeAccessLevel ?? false
            case .isOwner:
                return user.accesslLevels?.isOwner ?? false
            case .canReadTourList:
                return user.accesslLevels?.canReadTourList ?? false
            case .canWriteTourList:
                return user.accesslLevels?.canWriteTourList ?? false
            case .isGuide:
                return user.accesslLevels?.isGuide ?? false
            }
        }
        return false

    }
    
    func updateUserAccessLevel(localId:String, accessLevels: UserAccessLevelRealm){
        if let user = self.getUserInfo(localId: localId){
            try! realm.write({
                user.accesslLevels = accessLevels
            })
        }
    }
    
    func updateField(localId:String, updateField: UserDataFields, value:String){
        if let user = self.getUserInfo(localId: localId){
            try! realm.write({
                switch updateField{
                    
                case .firstName:
                    user.firstName = value
                case .secondName:
                    user.secondName = value
                case .birthdayDate:
                    break
                case .phone:
                    user.phone = value
                }
            })
        }
    }
    
    func updateBirhday(localId:String,date:Date){
        if let user = self.getUserInfo(localId: localId){
            try! realm.write({
                user.birthday = date
            })
        }
    }
    
    func updateImage(id:String, image:Data){
        if let user = self.getUserInfo(localId: id){
            try! realm.write({
                user.image = image
            })
        }
    }
    
    func deleteImage(id:String){
        if let user = self.getUserInfo(localId: id){
            try! realm.write({
                user.image = nil
            })
        }
    }
}
