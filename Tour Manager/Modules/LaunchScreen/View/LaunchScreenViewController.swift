//
//  LaunchScreenViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

final class LaunchScreenViewController: UIViewController {
    
    // MARK: - UserDefaults
    // MARK: - My varibles
    
    let keychain = KeychainService()
    let apiUserData = ApiManagerUserData()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let token = self.keychain.getAcessToken()
        let refreshToken = self.keychain.getRefreshToken()
        let companyId = self.keychain.getCompanyLocalId()
        
        (token != nil && refreshToken != nil && companyId != nil) ? MainAssembly.goToMainTabBar(view: self.view) : MainAssembly.goToLoginPage(view: self.view)
    }
}
