//
//  MainAssembly.swift
//  Tour Manager
//
//  Created by SHREDDING on 14.12.2023.
//

import Foundation
import UIKit

protocol MainAssemblyProtocol{
    static func createLaunchScreen() -> UIViewController
    
    static func goToLoginPage(view:UIView)
    static func goToMainTabBar(view:UIView)
}

final class MainAssembly:MainAssemblyProtocol{
    private static func createLoginViewController() -> UIViewController {
        let mainLogIn = LoginViewController()
        let presenter = LoginPresenter(view: mainLogIn)
        mainLogIn.presenter = presenter
        
        return BaseNavigationViewController(rootViewController: mainLogIn)
    }
    
    static func goToLoginPage(view: UIView) {
        let window = view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .fade
        options.duration = 0.5
        options.style = .easeOut
        
        let view = createLoginViewController()
        
        window?.set(rootViewController: view, options: options)
    }
    
    static func goToMainTabBar(view:UIView){
        let mainTabBar = mainTabBarViewController()
        
        let window = view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .fade
        options.duration = 0.5
        options.style = .easeOut
        
        window?.set(rootViewController: mainTabBar, options: options)
    }
    
    static func createLaunchScreen() -> UIViewController{
        return UIStoryboard(name: "Launch", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreenViewController")
    }
    
    static func goToLauchScreen(view:UIView){
        let launchScreen = createLaunchScreen()
        
        let window = view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .fade
        options.duration = 0.5
        options.style = .easeOut
        
        window?.set(rootViewController: launchScreen, options: options)
    }
    
}
