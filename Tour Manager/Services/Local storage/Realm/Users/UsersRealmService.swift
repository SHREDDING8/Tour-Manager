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
    func isUserExist(localId:String) -> Bool
    
    func getUserInfo(localId:String) -> UserRealm?
    func getAllUsers() -> Results<UserRealm>
    func deleteUsers()
    
    func getUserAccessLevel(localId:String, _ key:AccessLevelKeys) -> Bool
    func updateUserAccessLevel(localId:String, accessLevels: UserAccessLevelRealm)
    func updateField(localId:String, updateField: UserDataFields, value:String)
    func updateBirhday(localId:String,date:Date)
    
    func updateImage(userId:String, pictureId:String)
    func ovverideImages(userId:String, pictureIds:[String])
    
    func deleteImage(userId:String, pictureId:String)
}

class UsersRealmService:UsersRealmServiceProtocol{
    
    let realm = try! Realm()
        
    func setUserInfo(user: UserRealm){
        if let realmUser = realm.object(ofType: UserRealm.self, forPrimaryKey: user.localId){
            try! realm.write({
                realmUser.firstName = user.firstName
                realmUser.secondName = user.secondName
                realmUser.email = user.email
                realmUser.birthday = user.birthday
                realmUser.phone = user.phone
                realmUser.accesslLevels = user.accesslLevels
                realmUser.imageIDs = user.imageIDs
            })
        }else{
            try! realm.write({
                realm.add(user, update: .modified)
            })
        }
    }
    
    func getUserInfo(localId:String) -> UserRealm?{
        realm.object(ofType: UserRealm.self, forPrimaryKey: localId)
    }
    
    func isUserExist(localId:String)->Bool{
        realm.object(ofType: UserRealm.self, forPrimaryKey: localId) != nil
    }
    
    func getAllUsers() -> Results<UserRealm>{
        realm.objects(UserRealm.self)
    }
    
    func deleteUsers(){
        let users = realm.objects(UserRealm.self)
        try! realm.write({
            realm.delete(users)
        })
        
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
    
    func updateImage(userId:String, pictureId:String){
        if let user = self.getUserInfo(localId: userId){
            try! realm.write({
                user.imageIDs.insert(pictureId, at: 0)
            })
        }
    }
    
    func ovverideImages(userId:String, pictureIds:[String]){
        if let user = self.getUserInfo(localId: userId){
            try! realm.write({
                let newList:List<String> = List<String>()
                newList.append(objectsIn: pictureIds)
                user.imageIDs = newList
            })
        }
    }
    
    func deleteImage(userId:String, pictureId:String){
        if let user = self.getUserInfo(localId: userId){
            try! realm.write({
                if let index = user.imageIDs.firstIndex(of: pictureId){
                    user.imageIDs.remove(at: index)
                }
                
            })
        }
    }
}
