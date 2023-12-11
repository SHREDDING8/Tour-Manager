//
//  ProfileAssembly.swift
//  Tour Manager
//
//  Created by SHREDDING on 12.11.2023.
//

import Foundation
import UIKit

protocol ProfileAssemblyProtocol{
    static func createProfileViewController()->UIViewController
    static func createExtendedSettingsViewController() -> UIViewController
    static func createEmployeeListViewController() -> UIViewController
    
    static func createChangePasswordViewController() -> UIViewController
}

final class ProfileAssembly:ProfileAssemblyProtocol{
    
    static func createProfileViewController() -> UIViewController {
        let view = ProfileViewController()
        let presenter = ProfilePagePresenter(view: view)
        view.presenter = presenter
        return BaseNavigationViewController(rootViewController: view)
    }
    
    static func createExtendedSettingsViewController() ->UIViewController{
        
        let view = ExtendedSettingsViewController()
        
        let presenter = ExtendedSettingsPresenter(view: view)
        view.presenter = presenter
        
        return view
    }
    
    static func createEmployeeListViewController() -> UIViewController{
        let view = EmploeeTableViewController(style: .plain)
        let presenter = EmployeesListPresenter(view: view)
        view.presenter = presenter
        return view
    }
    
    static func createChangePasswordViewController() -> UIViewController{
        let view = ChangePasswordViewController()
        
        let presenter = ChangePasswordPresenter(view: view)
        view.presenter = presenter
        
        return view
    }
    
}
