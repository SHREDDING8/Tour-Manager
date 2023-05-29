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
}

enum TypeOfRegister{
    case emploee
    case company
}


class Controllers{
    
    let storyboardAuth = UIStoryboard(name: "Auth", bundle: nil)
    
    let storyboardMain = UIStoryboard(name: "Main", bundle: nil)
    
    public func getControllerAuth(_ controller:PossibleControllersAuth) -> UIViewController{
        return storyboardAuth.instantiateViewController(withIdentifier: controller.rawValue)
        }
    
    
    public func getControllerMain(_ controller:PossibleControllersMain) -> UIViewController{
        return storyboardMain.instantiateViewController(withIdentifier: controller.rawValue)
    }
    
    public func getLaunchScreen()->UIViewController{
        return UIStoryboard(name: "Launch", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreenViewController")
        
    }
}
