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
    fileprivate let refreshToken = AppDelegate.userDefaults.string(forKey: "refreshToken")
    
    // MARK: - My varibles
    
    let controllers = Controllers()
    let user = AppDelegate.user
    let alerts = Alert()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.token != nil && self.localId != nil && self.refreshToken != nil{
            self.user?.setToken(token: token!)
            self.user?.setLocalID(localId: localId!)
            self.user?.setRefreshToken(refreshToken: refreshToken!)
            
            self.user?.apiAuth.refreshToken(refreshToken: refreshToken ?? "", completion: { isRefreshed, newToken, error in
                if isRefreshed{
                    self.user?.setToken(token: newToken!)
                    UserDefaults.standard.set(newToken, forKey:  "authToken")
                    
                    
                    print("\n\n[REFRESH LAUCH: \(newToken!)]\n\n")
                    
                    self.user?.getUserInfoFromApi(completion: { isGetted, error in
                        
                        if isGetted{
                            self.controllers.goToMainTabBar(view: self.view, direction: .fade)
                        }else{
                            self.controllers.goToLoginPage(view: self.view, direction: .fade)
                        }

                    })
                    
                }else{
                    self.controllers.goToLoginPage(view: self.view, direction: .fade)
                }
            })
            
        } else{
            self.controllers.goToLoginPage(view: self.view, direction: .fade)
        }
    }
}
