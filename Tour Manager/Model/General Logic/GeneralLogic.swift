//
//  GeneralLogic.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.06.2023.
//

import Foundation
import UIKit

class GeneralLogic{
    
    public func callNumber(phoneNumber:String) {

      if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {

        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            application.open(phoneCallURL, options: [:], completionHandler: nil)
        }
      }
    }
}

class GeneralController{
    let tabBar:UITabBarController
    
    init(_ tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
}
