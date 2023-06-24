//
//  Controllers.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import Foundation
import UIKit


enum PossibleControllersAuth:String{
    
    case mainAuthController = "authNavigationController"
    
    case verifycontroller = "verifyEmailController"
    case addingPersonalInformation = "AddingPersonalDataViewController"
    case choiceOfTypeAccountViewController = "ChoiceOfTypeAccountViewController"
}

enum PossibleControllersMain:String{
    case mainTabBarController = "mainTabBarController"
    case profileNavigationViewController = "profileNavigationViewController"
    case changePasswordViewController = "ChangePasswordViewController"
    case emploeeTableViewController = "EmploeeTableViewController"
    case employeeViewController = "EmploeeViewController"
    
    case excursionManagementNavigationViewController = "ExcursionManagementNavigationViewController"
    
    case newExcursionTableViewController = "NewExcursionTableViewController"
    
    case addingNewComponentViewController = "AddingNewComponentViewController"
    
    
    case excursionsNavigationController = "ExcursionsNavigationController"
    
    case excursionForGuideTableViewController = "ExcursionForGuideTableViewController"
    
    case uiTableViewControllerContainer = "UITableViewControllerContainer"
}

enum TypeOfRegister{
    case emploee
    case company
}


class Controllers{
    
    // MARK: - Storyboards
    
    let storyboardAuth = UIStoryboard(name: "Auth", bundle: nil)
    
    let storyboardMain = UIStoryboard(name: "Main", bundle: nil)
    
    
    // MARK: - Get Controllers
    public func getControllerAuth(_ controller:PossibleControllersAuth) -> UIViewController{
        return storyboardAuth.instantiateViewController(withIdentifier: controller.rawValue)
    }
    
    
    public func getControllerMain(_ controller:PossibleControllersMain) -> UIViewController{
        return storyboardMain.instantiateViewController(withIdentifier: controller.rawValue)
    }
    
    public func getLaunchScreen()->UIViewController{
        return UIStoryboard(name: "Launch", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreenViewController")
        
    }
    
    public func goToLoginPage(view:UIView, direction: UIWindow.TransitionOptions.Direction){
        let mainLogIn = self.getControllerAuth(.mainAuthController)
        
        let window = view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = direction
        options.duration = 0.5
        options.style = .easeOut
        
        window?.set(rootViewController: mainLogIn, options: options)
    }
    
    public func goToMainTabBar(view:UIView, direction: UIWindow.TransitionOptions.Direction){
        let mainTabBar = self.getControllerMain(.mainTabBarController)
        
        let window = view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = direction
        options.duration = 0.5
        options.style = .easeOut
        
        window?.set(rootViewController: mainTabBar, options: options)
    }
}
