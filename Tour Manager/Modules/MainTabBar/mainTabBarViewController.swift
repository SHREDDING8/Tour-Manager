//
//  mainTabBarViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import UIKit
import AlertKit

class mainTabBarViewController: UITabBarController {
    
    var presenter: MainTabBarPresenterProtocol?
    
    let controllers = Controllers()
    let alerts = Alert()
        
    let activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        indicator.style = .large
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainTabBarPresenter(view: self)
        
        AppDelegate.tabBar = self
                        
        self.view.backgroundColor = UIColor(named: "background")
        
        updateControllers()
        
        self.presenter?.getAccessLevelFromApi()
                
    }
    
        
    fileprivate func configureActivityIndicator(){
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
}

extension mainTabBarViewController:MainTabBarViewProtocol{
    func unknownError() {
        AlertKitAPI.present(title: "Неизвестная ошибка", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
    func updateControllers() {
        var controllersList:[UIViewController] = []
        
        let profileNavController = controllers.getControllerMain(.profileNavigationViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 1)
        
        let excursionManagementNavViewController = controllers.getControllerMain(.excursionManagementNavigationViewController)
        
        excursionManagementNavViewController.tabBarItem = UITabBarItem(title: "Управление", image: UIImage(systemName: "calendar"), tag: 2)
        
        let excursionsNavigationController = controllers.getControllerMain(.excursionsNavigationController)
        excursionsNavigationController.tabBarItem = UITabBarItem(title: "Экскурсии", image: UIImage(systemName: "calendar"), tag: 2)



        if (self.presenter?.isUserGuide() ?? false){
            controllersList.append(excursionsNavigationController)
        }


        if (self.presenter?.isUserCanReadAllTours() ?? false) {
            controllersList.append(excursionManagementNavViewController)
        }
                
        controllersList.append(profileNavController)
        
        self.setViewControllers(controllersList, animated: true)
        
        if controllersList.count == 3{
            self.selectedIndex = 1
        }
    }
    
}
