//
//  File.swift
//  Tour Manager
//
//  Created by SHREDDING on 12.10.2023.
//

import Foundation
import UIKit

struct UsersModel{
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
    var image:UIImage?
    var accessLevels:UserAccessLevels
    
    var fullName:String{
        self.firstName + " " + self.secondName
    }
}
