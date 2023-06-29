//
//  NotificationCenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.06.2023.
//

import Foundation
import UserNotifications

class LocalNotifications: NSObject{
    
    
    public func createRememberWorkDayNotification(tourDate:Date){
        let rememberNotification = UNMutableNotificationContent()
        
        rememberNotification.title = "Tour Manager"
        rememberNotification.body = "У вас завтра есть экскурсии"
        
        rememberNotification.categoryIdentifier = "remember"
       
        let dateTrigger = Calendar.current.date(byAdding: .day, value: -1, to: tourDate)!
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dateTrigger)
        
        dateComponents.hour = 19
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "RememberWorkDayNotification\(dateTrigger.birthdayToString())", content: rememberNotification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
    }
}

extension LocalNotifications:UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print(response.notification.request.identifier)
    }
    
}
