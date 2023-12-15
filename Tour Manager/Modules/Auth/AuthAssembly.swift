//
//  AuthAssembly.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.08.2023.
//

import Foundation
import UIKit

protocol AuthAssemblyProtocol{
    static func createVerifyEmailViewController(loginModel:loginData) -> UIViewController
    static func createTypeOfAccountViewController() -> UIViewController
    static func createSetInfoViewController(type: AddingPersonalDataPresenter.TypeOfAccount) -> UIViewController
}

class AuthAssembly:AuthAssemblyProtocol{
    static func createVerifyEmailViewController(loginModel:loginData) -> UIViewController{
        let view = VerifyEmailViewController()
        let presenter = VerifyEmailPresenter(view: view, loginData: loginModel)
        view.presenter = presenter
        
        return view
    }
    
    static func createTypeOfAccountViewController() -> UIViewController{
        let vc = TypeAccountViewController()
        return vc
    }
    
    static func createSetInfoViewController(type: AddingPersonalDataPresenter.TypeOfAccount) -> UIViewController{
        let view = AddingPersonalDataViewController()
        let presenter = AddingPersonalDataPresenter(view: view, typeOfAccount: type)
        view.presenter = presenter
        
        return view
    }
}
