//
//  AuthAssembly.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation
import UIKit

protocol AuthAssemblyProtocol{
    static func loginController()->UIViewController
}

class AuthAssembly:AuthAssemblyProtocol{
    
    static let storyboardAuth = UIStoryboard(name: "Auth", bundle: nil)
    
    static let storyboardMain = UIStoryboard(name: "Main", bundle: nil)
    
    
    // MARK: - Get Controllers
    static public func loginController() -> UIViewController{
        let loginVC =  storyboardAuth.instantiateViewController(withIdentifier: "authNavigationController")
                
        return loginVC
    }
}
