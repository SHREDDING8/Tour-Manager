//
//  Profile.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.05.2023.
//

import Foundation


// MARK: - enum of classification cell in Page Profile

class Profile{
    let user = AppDelegate.user
    
    
    public enum ProfilePersonalDataCellType{
        typealias RawValue = (String,Int)
        case firstName
        case lastName
        case birthday
        case email
        case phone
        case changePassword
        
        init?(index:Int){
            switch index{
            case 0: self = .firstName
            case 1: self = .lastName
            case 2: self = .birthday
            case 3: self = .email
            case 4: self = .phone
            case 5: self = .changePassword
                
            default:
                return nil
            }
        }
        
        var rawValue: RawValue{
            switch self{
            case .firstName:
                return ("Имя",0)
            case .lastName:
                return ("Фамилия",1)
            case .birthday:
                return ("Дата рождения",2)
            case .email:
                return ("Email",3)
            case .phone:
                return ("Телефон",4)
            case .changePassword:
                return ("Изменить пароль",5)
            }
        }
        
        
    }
    
    public func getProfilePersonalDataFromUser(type:ProfilePersonalDataCellType)->String{
        switch type{
            
        case .firstName:
            return self.user?.getFirstName() ?? ""
        case .lastName:
            return self.user?.getSecondName() ?? ""
        case .birthday:
            return self.user?.getBirthday() ?? ""
        case .email:
            return self.user?.getEmail() ?? ""
        case .phone:
            return self.user?.getPhone() ?? ""
        case .changePassword:
            return ""
        }
        
        
        
    }
    
    
    public func getProfileCellType(index:Int)->ProfilePersonalDataCellType{
        return ProfilePersonalDataCellType(index: index) ?? .firstName
        
    }
}

enum CellTypeProfilePage{
    typealias RawValue = (String,Int)
    case CompanyName
    case firstName
    case lastName
    case birthday
    case email
    case phone
    
    case changePassword
    case admins
    case guides
    
    init?(index:Int){
        switch index{
        case 0: self = .CompanyName
        case 1: self = .firstName
        case 2: self = .lastName
        case 3: self = .birthday
        case 4: self = .email
        case 5: self = .phone
        case 6: self = .changePassword
        case 7: self = .admins
        case 8: self = .guides
            
        default:
            return nil
        }
    }
    
    var rawValue: RawValue{
        switch self{
        case .CompanyName:
            return ("Название компаниии",0)
        case .firstName:
            return ("Имя",1)
        case .lastName:
            return ("Фамилия",2)
        case .birthday:
            return ("Дата рождения",3)
        case .email:
            return ("Email",4)
        case .phone:
            return ("Телефон",5)
        case .changePassword:
            return ("Изменить пароль",6)
        case .admins:
            return ("Админы",7)
        case .guides:
            return ("Эксурсоводы",8)
        }
    }
}

// MARK: - test Profile

let profile:[CellTypeProfilePage:String] = [
    .CompanyName: "Inno Travel",
    .firstName: "Мария",
    .lastName: "Мельник",
    .email: "test@mail.ru",
    .phone: "8 (904) 781-35-90"
]
