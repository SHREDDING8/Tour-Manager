//
//  ConvertDate.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.05.2023.
//

import Foundation
// MARK: - ConvertDateProtocol
protocol ConvertDateProtocol{
    
    
    // MARK: - Birthday
    func birthdayToString(date:Date)->String
    func birthdayFromString(dateString:String)->Date
}


class ConvertDate{
    
    // MARK: - Birthday Variables
    private let dateFormatterBirthday = DateFormatter()
    private let templateBirthday = "dd.MM.yyyy"
    
    // MARK: - Inits
    init(){
        self.dateFormatterBirthday.dateFormat = self.templateBirthday
    }
    
    
    // MARK: - Birthday funcs
    public func birthdayToString(date:Date)->String{
        
        let dateString = dateFormatterBirthday.string(from: date)
        
        return dateString
    }
    
    public func birthdayFromString(dateString:String)->Date{
        let date = dateFormatterBirthday.date(from: dateString) ?? Date.now
        return date
    }
    
}
