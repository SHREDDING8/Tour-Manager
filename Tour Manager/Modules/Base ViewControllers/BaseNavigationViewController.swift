//
//  BaseNavigationViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.12.2023.
//

import UIKit

class BaseNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor(resource: .blueText)
    }
    
}
