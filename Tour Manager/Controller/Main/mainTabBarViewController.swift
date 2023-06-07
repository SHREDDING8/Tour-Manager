//
//  mainTabBarViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import UIKit

class mainTabBarViewController: UITabBarController {
    let controllers = Controllers()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileNavController = controllers.getControllerMain(.profileNavigationViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 1)
        
        
        let excursionManagementNavViewController = controllers.getControllerMain(.excursionManagementNavigationViewController)
        
        excursionManagementNavViewController.tabBarItem = UITabBarItem(title: "Управление", image: UIImage(systemName: "calendar"), tag: 2)
        
        
        
        self.viewControllers = [excursionManagementNavViewController,profileNavController]
        
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
