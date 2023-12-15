//
//  Controllers.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import Foundation
import UIKit


enum PossibleControllersAuth:String{
    
    case verifycontroller = "verifyEmailController"
    case addingPersonalInformation = "AddingPersonalDataViewController"
    case choiceOfTypeAccountViewController = "ChoiceOfTypeAccountViewController"
}

enum TypeOfRegister{
    case emploee
    case company
}


class Controllers{
    
    // MARK: - Storyboards
    
    let storyboardAuth = UIStoryboard(name: "Auth", bundle: nil)
    
    // MARK: - Get Controllers
    public func getControllerAuth(_ controller:PossibleControllersAuth) -> UIViewController{
        return storyboardAuth.instantiateViewController(withIdentifier: controller.rawValue)
    }
    
}
