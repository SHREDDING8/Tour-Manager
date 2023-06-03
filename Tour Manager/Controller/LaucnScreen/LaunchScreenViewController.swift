//
//  LaunchScreenViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    fileprivate let token = AppDelegate.userDefaults.string(forKey: "authToken")
    fileprivate let localId = AppDelegate.userDefaults.string(forKey: "localId")
    let controllers = Controllers()
    let user = AppDelegate.user

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.token != nil && self.localId != nil{
            self.user?.setToken(token: token!)
            self.user?.setLocalID(localId: localId!)
            
            self.user?.getUserInfoFromApi(completion: { isGetted, error in
                
                if error == nil && isGetted{
                    self.goToMainTabBar()
                } else{
                    self.goToLogInPage()
                }
            })
        } else{
            self.goToLogInPage()
        }
    }
    
    
    
    // MARK: - Navigation
    
    fileprivate func goToMainTabBar(){
        let mainTabBar = self.controllers.getControllerMain(.mainTabBarController)

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .fade
        options.duration = 0.5
        options.style = .easeIn
        
        window?.set(rootViewController: mainTabBar,options: options)
    }
    
    fileprivate func goToLogInPage(){
        let mainLogIn = self.controllers.getControllerAuth(.mainAuthController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .fade
        options.duration = 0.5
        options.style = .easeIn
        
        window?.set(rootViewController: mainLogIn,options: options)
        
    }

    

}
