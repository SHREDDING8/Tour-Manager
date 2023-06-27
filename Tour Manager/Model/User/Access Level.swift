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
            return "Чтение всех экскурсий"
        case .canReadTourList:
            return "Изменение экскурсий"
        case .isGuide:
            return "Эксурсовод"
        }
    }
    
    
    public func getAccessLevelFromApi(completion: @escaping (Bool, customErrorCompany?)->Void){
        
        self.apiCompany.getCurrentAccessLevel(token: self.getToken(), companyId: self.company.getLocalIDCompany()) { accessLevel, error in
            if error != nil{
                completion(false,error)
            }
            
            if accessLevel != nil{
                self.accessLevel[.readCompanyEmployee] = accessLevel?.read_company_employee
                self.accessLevel[.readLocalIdCompany] = accessLevel?.read_local_id_company
                self.accessLevel[.readGeneralCompanyInformation] = accessLevel?.read_general_company_information
                self.accessLevel[.writeGeneralCompanyInformation] = accessLevel?.write_general_company_information
                self.accessLevel[.canChangeAccessLevel] = accessLevel?.can_change_access_level
                self.accessLevel[.isOwner] = accessLevel?.is_owner
                
                self.accessLevel[.canReadTourList] = accessLevel?.can_read_tour_list
                self.accessLevel[.canWriteTourList] = accessLevel?.can_write_tour_list
                self.accessLevel[.isGuide] = accessLevel?.is_guide
                
                completion(true,nil)
            }
        }
    }
    
    public func updateAccessLevel(employe:User, accessLevel:AccessLevelEnum, value:Bool, completion: @escaping (Bool, customErrorCompany?)->Void ){
        
        employe.accessLevel[accessLevel] = value
        
        let jsonData = SendUpdateUserAccessLevel(
            token: self.getToken(),
            company_id: self.company.getLocalIDCompany(),
            target_uid: employe.getLocalID() ?? "",
            can_change_access_level: employe.getAccessLevel(rule: .canChangeAccessLevel),
            can_read_tour_list: employe.getAccessLevel(rule: .canReadTourList),
            can_write_tour_list: employe.getAccessLevel(rule: .canWriteTourList),
            is_guide: employe.getAccessLevel(rule: .isGuide),
            read_company_employee: employe.getAccessLevel(rule: .readCompanyEmployee),
            read_general_company_information: employe.getAccessLevel(rule: .readGeneralCompanyInformation),
            read_local_id_company: employe.getAccessLevel(rule: .readLocalIdCompany),
            write_general_company_information: employe.getAccessLevel(rule: .writeGeneralCompanyInformation)
        )
        
        apiCompany.updateUserAccessLevel(jsonData) { isUpdated, error in
            completion(isUpdated,error)
        }
        
    }
}
