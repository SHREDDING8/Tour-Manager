//
//  AppDelegate.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.04.2023.
//

import UIKit
import UserNotifications
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public static var tabBar:UITabBarController? = nil
            
    let keychainService = KeychainService()
    let userDefaultsService:UserDefaultsServiceProtocol = UserDefaultsService()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // File url of existing realm config
        let defaultRealm = Realm.Configuration.defaultConfiguration.fileURL!
        // Container for newly created App Group Identifier
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ProcessInfo.processInfo.environment["REALM_GROUP"]!)
        // Shared path of realm config
        let realmURL = container?.appendingPathComponent("default.realm")
        // Config init
        var config: Realm.Configuration!
        
        if FileManager.default.fileExists(atPath: defaultRealm.path) {
            do {
              // Replace old config with the new one
                _ = try FileManager.default.replaceItemAt(realmURL!, withItemAt: defaultRealm)

               config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
            } catch {
               print("Error info: \(error)")
            }
        } else {
             config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        }

        // Lastly init realm config to default config
        Realm.Configuration.defaultConfiguration = config
        
        
        registerForPushNotifications()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        if userDefaultsService.isFirstLaunch(){
            keychainService.removeAllData()
            let realm =  try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
        }
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let tokenParts = deviceToken.map { data -> String in
        return String(format: "%02.2hhx", data)
      }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
        self.keychainService.setDeviceToken(token: token)
        
        
        
        
        _ = UNUserNotificationCenter.current()

//        // 1. Create Custom Actions
//        
//        let showMeMoreAction = UNNotificationAction(identifier: "showMeMoreIdentifier",
//                                        title: "Show me more",
//                                                    options: [.foreground])
//        
//        
//        let snoozeAction = UNNotificationAction(identifier: "snoozeIdentifier",
//                                                title: "Snooze",
//                                                options: [])
//        let deleteAction = UNNotificationAction(identifier: "deleteIdentifier",
//                                                title: "Delete",
//                                                options: [.destructive])
//
//        // 2. Register Custom Actions For Category
//        let category1 = UNNotificationCategory(identifier: "myActionCategoryIdentifier1",
//                                               actions: [showMeMoreAction],
//                                               intentIdentifiers: [])
//        
//        let category2 = UNNotificationCategory(identifier: "myActionCategoryIdentifier2",
//                                               actions: [snoozeAction, deleteAction],
//                                               intentIdentifiers: [])
//
//        // 3. Register Categories with OS
//        center.setNotificationCategories([category1, category2])
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
//      print("Failed to register: \(error)")
    }
    
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
//            print("Permission granted: \(granted)")
            UNUserNotificationCenter.current().delegate = self
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    

}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       
//        let notificationUserInfo = notification.request.content.userInfo
        
//        let notificationType =  notificationUserInfo["notification_type"] as? String
            
        completionHandler([.banner,.badge,.sound])
       
        

    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
}

