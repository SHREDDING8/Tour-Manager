//
//  mainTabBarViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import UIKit

class mainTabBarViewController: UITabBarController {
    let controllers = Controllers()
    
    let user = AppDelegate.user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user?.getAccessLevelFromApi(completion: { isGetted, error in
            if isGetted{
                self.getViewControllers()
            }
        })
    }
    
    
    fileprivate func getViewControllers(){
        
        let profileNavController = controllers.getControllerMain(.profileNavigationViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 1)
        
        
        let excursionManagementNavViewController = controllers.getControllerMain(.excursionManagementNavigationViewController)
        
        excursionManagementNavViewController.tabBarItem = UITabBarItem(title: "Управление", image: UIImage(systemName: "calendar"), tag: 2)
        
        
        let excursionsNavigationController = controllers.getControllerMain(.excursionsNavigationController)
        excursionsNavigationController.tabBarItem = UITabBarItem(title: "Экскурсии", image: UIImage(systemName: "calendar"), tag: 2)
        
        var controllersList:[UIViewController] = []
        
        if (self.user?.getAccessLevel(rule: .isGuide) ?? false){
            controllersList.append(excursionsNavigationController)
        }
        
        
        if (self.user?.getAccessLevel(rule: .canReadTourList) ?? false) {
            controllersList.append(excursionManagementNavViewController)
        }
        
        controllersList.append(profileNavController)
        self.viewControllers = controllersList
        
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
