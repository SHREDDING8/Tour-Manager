//
//  PushNotificationCenter.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.06.2023.
//

import Foundation
import NotificationCenter

class PushNotificationCenter:NSObject{
    
}

extension PushNotificationCenter:UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound,.list])
    }
}
