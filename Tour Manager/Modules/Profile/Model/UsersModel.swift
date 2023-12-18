//
//  File.swift
//  Tour Manager
//
//  Created by SHREDDING on 12.10.2023.
//

import Foundation
import UIKit

struct UsersModel{
    
    enum AccessLevel{
        case readCompanyEmployee
        case readLocalIdCompany
        case readGeneralCompanyInformation
        case writeGeneralCompanyInformation
        case canChangeAccessLevel
        case isOwner
        case canReadTourList
        case canWriteTourList
        case isGuide
    }
    
    struct UserAccessLevels{
        var readCompanyEmployee:Bool
        var readLocalIdCompany:Bool
        var readGeneralCompanyInformation:Bool
        var writeGeneralCompanyInformation:Bool
        var canChangeAccessLevel:Bool
        var isOwner:Bool
        var canReadTourList:Bool
        var canWriteTourList:Bool
        var isGuide:Bool
    }
    
    var localId:String
    var firstName:String
    var secondName:String
    var email:String
    var phone:String
    var birthday:Date
    var images:[(id:String, image:UIImage)]
    var accessLevels:UserAccessLevels
    
    var fullName:String{
        self.firstName + " " + self.secondName
    }
}
