//
//  Access Level.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.06.2023.
//

import Foundation

extension User{
    // MARK: - level Access
    public func getAccessLevel(rule:AccessLevelEnum) -> Bool{
        let result = self.accessLevel[rule]
        return result ?? false
    }
    
    public func getNumberOfAccessLevel()->Int{
        
        return self.accessLevel.count
        
    }
    
    public func getAccessLevelRule(index:Int)->AccessLevelEnum{
        return AccessLevelEnum(index: index) ?? .readGeneralCompanyInformation

    }
    
    public func getAccessLevelLabel(rule:AccessLevelEnum)->String{
        switch rule{
            
        case .isOwner:
            return "Владелец компании"
        case .readGeneralCompanyInformation:
            return "Чтение общей информации о компании"
        case .writeGeneralCompanyInformation:
            return "Изменение общей информации о компании"
        case .readLocalIdCompany:
            return "Чтение Id компании"
        case .readCompanyEmployee:
            return "Просмотр работников компании"
        case .canChangeAccessLevel:
            return "Изменение прав доступа работников компании"
        case .canWriteTourList:
            return "Изменение экскурсий"
        case .canReadTourList:
            return  "Чтение всех экскурсий"
        case .isGuide:
            return "Эксурсовод"
        }
    }
}
