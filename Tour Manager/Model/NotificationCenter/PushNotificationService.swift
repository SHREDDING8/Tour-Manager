//
//  PushNotificationCenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.06.2023.
//

import Foundation
import NotificationCenter


public enum NotificationType:String{
    case removeTour = "remove_tour"
    case addTour = "add_tour"
    case updateTour = "update_tour"
    case guideTourStatus = "guide_tour_status"
    
}

class PushNotificationService:NSObject{
    
    let localNotifications = LocalNotifications()
    
    let apiManagerTours = ApiManagerExcursions()
    let apiManagerAuth = ApiManagerAuth()
    
    let userDefaults = WorkWithUserDefaults()
    
//    public func removeTour(notificationUserInfo:[AnyHashable:Any]){
//        let date = (notificationUserInfo["tour_date"] as? String) ?? ""
//        let time = (notificationUserInfo["tour_time_start"] as? String) ?? ""
//        let companyId = (notificationUserInfo["companyId"] as? String) ?? ""
//        
//        
//        
//        localNotifications.removeRememberTour(tourDate: Date.dateAndTimeToDate(dateString: date, timeString: time))
//        
//        if true{
//            
//            if let refreshToken = self.userDefaults.getRefreshToken(){
//                
//                self.apiManagerAuth.refreshToken(refreshToken: refreshToken) { isGetted, newToken, error in
//                    if error != nil{
//                        self.localNotifications.removeRememberWorkDayNotification(tourDate:  Date.dateAndTimeToDate(dateString: date, timeString: time))
//                        return
//                    }
//                    
//                    if isGetted{
//                        self.userDefaults.setAuthToken(token: newToken!)
//                    }
//                    
//                    self.removeRememberWorkDayNotificationWithToken(date: date, time: time, companyId: companyId)
//                    
//                    
//                }
//                
//            }else{
//                self.localNotifications.removeRememberWorkDayNotification(tourDate:  Date.dateAndTimeToDate(dateString: date, timeString: time))
//            }
//            
//        }else{
//            self.removeRememberWorkDayNotificationWithToken(date: date, time: time,companyId: companyId)
//            
//        }
//        
//    }
    
    private func removeRememberWorkDayNotificationWithToken(date:String, time:String,companyId:String){
        if let token = self.userDefaults.getAuthToken(){
            apiManagerTours.GetExcursionsForGuides(token: token, companyId: companyId, date: date) { isGetted, response, error in
                
                if error != nil{
                    self.localNotifications.removeRememberWorkDayNotification(tourDate:  Date.dateAndTimeToDate(dateString: date, timeString: time))
                    return
                }
                
                if response?.count == 0{
                    self.localNotifications.removeRememberWorkDayNotification(tourDate:  Date.dateAndTimeToDate(dateString: date, timeString: time))
                    return
                }
            }
        }else{
            self.localNotifications.removeRememberWorkDayNotification(tourDate:  Date.dateAndTimeToDate(dateString: date, timeString: time))
            return
        }
    }
    
//    public func updateTour(notificationUserInfo:[AnyHashable:Any]){
//        let oldInfo = notificationUserInfo["old_tour_info"] as? [String:String]
//        let newInfo = notificationUserInfo["new_tour_info"] as? [String:String]
//       
//        
//        if oldInfo != nil{
//            
//            self.removeTour(notificationUserInfo: oldInfo ?? [:])
//            
//            if let newInf = newInfo{
//                
//                let newDate = (newInf["tour_date"]) ?? ""
//                let newtTime = (newInf["tour_time_start"]) ?? ""
//                
//                localNotifications.createRememberTour(tourDate: Date.dateAndTimeToDate(dateString: newDate, timeString: newtTime))
//                localNotifications.createRememberWorkDayNotification(tourDate: Date.dateAndTimeToDate(dateString: newDate, timeString: newtTime))
//            }
//        }
//    }
    
    public func changeGuideStatus(notificationUserInfo:[AnyHashable:Any]){
        
        let date = (notificationUserInfo["tour_date"] as? String) ?? ""
        let time = (notificationUserInfo["tour_time_start"] as? String) ?? ""
        let status = (notificationUserInfo["guide_status"] as? String) ?? ""
        
        
        if status == "accept"{
            localNotifications.createRememberTour(tourDate: Date.dateAndTimeToDate(dateString: date, timeString: time))
            localNotifications.createRememberWorkDayNotification(tourDate: Date.dateAndTimeToDate(dateString: date, timeString: time))
        }
        
    }
    
}
