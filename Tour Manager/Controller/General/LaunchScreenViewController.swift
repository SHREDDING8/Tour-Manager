//
//  LaunchScreenViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    // MARK: - UserDefaults
    // MARK: - My varibles
    
    let controllers = Controllers()
    let user = AppDelegate.user
    let alerts = Alert()
    
    let userDefaultsService = WorkWithUserDefaults()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let token = self.userDefaultsService.getAuthToken()
        let localId = self.userDefaultsService.getLocalId()
        
        if token != nil && localId != ""{
            self.user?.setToken(token: token!)
            self.user?.setLocalID(localId: localId)
            
            self.user?.getUserInfoFromApi(completion: { isGetted, error in
                
//                print("Lauch: \(isGetted) \(error)")
                
                if isGetted{
                    self.controllers.goToMainTabBar(view: self.view, direction: .fade)
                }else if error == .notConnected{
                    self.controllers.goToNoConnection(view: self.view, direction: .fade)
                    
                }else{
                    self.controllers.goToLoginPage(view: self.view, direction: .fade)
                }
            })
            
        } else{
            self.controllers.goToLoginPage(view: self.view, direction: .fade)
        }
    }
}
