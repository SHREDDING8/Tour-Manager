//
//  UsersDatabase.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.08.2023.
//

import Foundation
import RealmSwift


final class UserRealm: Object {
    @Persisted(primaryKey: true) var localId:String
    @Persisted var firstName:String
    @Persisted var secondName:String
    @Persisted var email:String?
    @Persisted var phone:String?
    @Persisted var birthday:Date?
    @Persisted var imageIDs:List<String>
    
    @Persisted var accesslLevels:UserAccessLevelRealm?
    
    convenience init(
        localId:String,
        firstName:String,
        secondName:String,
        email:String,
        phone:String,
        birthday:Date,
        imageIDs:[String],
        accesslLevels:UserAccessLevelRealm? = nil
    ) {
        self.init()
        self.localId = localId
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.phone = phone
        self.birthday = birthday
        
        let newImageIDs = List<String>()
        newImageIDs.append(objectsIn: imageIDs)
        self.imageIDs = newImageIDs
        self.accesslLevels = accesslLevels
    }
    
    convenience init (
        localId:String,
        firstName:String,
        secondName:String){
            self.init()
            self.localId = localId
            self.firstName = firstName
            self.secondName = secondName
        }
}

final class UserAccessLevelRealm: EmbeddedObject{
    @Persisted var readCompanyEmployee:Bool
    @Persisted var readLocalIdCompany:Bool
    @Persisted var readGeneralCompanyInformation:Bool
    @Persisted var writeGeneralCompanyInformation:Bool
    @Persisted var canChangeAccessLevel:Bool
    @Persisted var isOwner:Bool
    @Persisted var canReadTourList:Bool
    @Persisted var canWriteTourList:Bool
    @Persisted var isGuide:Bool
    
    convenience init(readCompanyEmployee: Bool, readLocalIdCompany: Bool, readGeneralCompanyInformation: Bool, writeGeneralCompanyInformation: Bool, canChangeAccessLevel: Bool, isOwner: Bool, canReadTourList: Bool, canWriteTourList: Bool, isGuide: Bool) {
        self.init()
        self.readCompanyEmployee = readCompanyEmployee
        self.readLocalIdCompany = readLocalIdCompany
        self.readGeneralCompanyInformation = readGeneralCompanyInformation
        self.writeGeneralCompanyInformation = writeGeneralCompanyInformation
        self.canChangeAccessLevel = canChangeAccessLevel
        self.isOwner = isOwner
        self.canReadTourList = canReadTourList
        self.canWriteTourList = canWriteTourList
        self.isGuide = isGuide
    }
}
