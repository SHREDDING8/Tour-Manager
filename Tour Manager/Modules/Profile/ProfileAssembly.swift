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
    static func createExtendedSettingsViewController() ->UIViewController
}

final class ProfileAssembly:ProfileAssemblyProtocol{
    
    static func createProfileViewController() -> UIViewController {
        let view = ProfileNewViewController()
        let presenter = ProfilePagePresenter(view: view)
        view.presenter = presenter
        return UINavigationController(rootViewController: view)
    }
    
    static func createExtendedSettingsViewController() ->UIViewController{
        
        let view = ExtendedSettingsViewController()
        
        let presenter = ExtendedSettingsPresenter(view: view)
        view.presenter = presenter
        
        return view
    }
    
}
