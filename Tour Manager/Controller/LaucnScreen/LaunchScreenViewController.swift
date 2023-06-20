//
//  LaunchScreenViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    // MARK: - UserDefaults
    
    fileprivate let token = AppDelegate.userDefaults.string(forKey: "authToken")
    fileprivate let localId = AppDelegate.userDefaults.string(forKey: "localId")
    
    // MARK: - My varibles
    
    let controllers = Controllers()
    let user = AppDelegate.user
    
    // MARK: - Life Cycle
    
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
                    self.controllers.goToMainTabBar(view: self.view, direction: .fade)
                } else{
                    self.controllers.goToLoginPage(view: self.view, direction: .fade)
                }
            })
        } else{
            self.controllers.goToLoginPage(view: self.view, direction: .fade)
        }
    }
}
