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
}

class AuthAssembly:AuthAssemblyProtocol{
    static func createVerifyEmailViewController(loginModel:loginData) -> UIViewController{
        let view = VerifyEmailViewController()
        let presenter = VerifyEmailPresenter(view: view, loginData: loginModel)
        view.presenter = presenter
        
        return view
    }
}
