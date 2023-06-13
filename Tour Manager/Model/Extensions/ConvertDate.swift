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


extension Date{
    
    
    
    // MARK: - Birthday funcs
    public func birthdayToString()->String{
        let dateFormatterBirthday = DateFormatter()
        let templateBirthday = "dd.MM.yyyy"
        dateFormatterBirthday.dateFormat = templateBirthday
        
        let dateString = dateFormatterBirthday.string(from: self)
        
        return dateString
    }
    
    static public func birthdayFromString(dateString:String)->Date{
        
        let dateFormatterBirthday = DateFormatter()
        let templateBirthday = "dd.MM.yyyy"
        dateFormatterBirthday.dateFormat = templateBirthday
        
        let date = dateFormatterBirthday.date(from: dateString) ?? Date.now
        return date
    }
    
    public func timeToString()->String{
        let dateFormatterBirthday = DateFormatter()
        let templateBirthday = "HH:mm"
        dateFormatterBirthday.dateFormat = templateBirthday
        
        let timeString = dateFormatterBirthday.string(from: self)
        return timeString
        
    }
    
    static public func dateAndTimeToDate(dateString:String?, timeString:String)->Date{
        let dateFormatterBirthday = DateFormatter()
        if dateString != nil{
            let templateBirthday = "dd.MM.yyyy HH:mm"
            dateFormatterBirthday.dateFormat = templateBirthday
            
            let date = dateFormatterBirthday.date(from: "\(dateString!) \(timeString)") ?? Date.now
            
            return date
        }else{
            let templateBirthday = "HH:mm"
            dateFormatterBirthday.dateFormat = templateBirthday
            
            let date = dateFormatterBirthday.date(from: "\(timeString)") ?? Date.now
            return date
        }
       
       
        
        
    }
    
}
