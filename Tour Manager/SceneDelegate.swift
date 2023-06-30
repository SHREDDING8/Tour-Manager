//
//  SceneDelegate.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.04.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let contollers = Controllers()
    let user = AppDelegate.user
    
    var sceneIsActive:Bool = false


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        print(UIDevice.current.model)
        print(UIDevice.current.batteryState)
        print(UIDevice.current.batteryLevel)
        print(UIDevice.current.identifierForVendor)
        print(UIDevice.current.localizedModel)
        print(UIDevice.current.name)
        print(UIDevice.current.systemName)
        print(UIDevice.current.systemVersion)
        
        
        if let windowScene = (scene as? UIWindowScene){
            let window = UIWindow(windowScene: windowScene)
            let launch = self.contollers.getLaunchScreen()
            window.rootViewController = launch
            self.window = window
            window.makeKeyAndVisible()
        } else { return }
        
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        self.sceneIsActive = true
        
        setTimerRefreshToken()
        let tabBar = AppDelegate.tabBar as? mainTabBarViewController
    
        tabBar?.setLoading()
    }
    
    private func setTimerRefreshToken(){
        
        var seconds = 0
        var limit = 0
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if seconds == limit {
                let refreshToken = AppDelegate.userDefaults.string(forKey: "refreshToken")
                self.user?.apiAuth.refreshToken(refreshToken: refreshToken ?? "", completion: { isRefreshed, newToken, error in
                    if isRefreshed{
                        self.user?.setToken(token: newToken!)
                        print("\n\n[REFRESH: \(newToken!)]\n\n")
                        UserDefaults.standard.set(newToken, forKey:  "authToken")
                        
                        let tabBar = AppDelegate.tabBar as? mainTabBarViewController
                    
                        tabBar?.stopLoading()
                    }
                })
                limit += 3300
                
            }
            seconds += 1
            if !self.sceneIsActive{
                timer.invalidate()
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        self.sceneIsActive = false
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

