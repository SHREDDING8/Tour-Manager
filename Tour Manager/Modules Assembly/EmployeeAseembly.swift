//
//  EmployeeAseembly.swift
//  Tour Manager
//
//  Created by SHREDDING on 12.10.2023.
//

import Foundation
import UIKit

protocol EmployeeAseemblyProtocol{
    static func EmployeeDetailController(user:UsersModel) -> UIViewController
}

final class EmployeeAseembly:EmployeeAseemblyProtocol{
    
    static func EmployeeDetailController(user:UsersModel) -> UIViewController{
        
        let view = EmploeeViewController()
        let presenter = EmployeePresenter(view: view, user: user)
        view.presenter = presenter
        
        return view
    }
    
}
