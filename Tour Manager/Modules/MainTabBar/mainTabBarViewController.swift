//
//  mainTabBarViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 26.05.2023.
//

import UIKit

class mainTabBarViewController: UITabBarController {
    
    var presenter: MainTabBarPresenterProtocol?
    
    let controllers = Controllers()
    let alerts = Alert()
    
    var loadview:LoadView!
    
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
        
        self.loadview = LoadView(viewController: self)
        
        configureActivityIndicator()
        
        self.view.backgroundColor = UIColor(named: "background")
        
        self.presenter?.getAccessLevelFromApi(completion: { isGetted, error in
            
            if let err = error{
                self.alerts.errorAlert(self, errorCompanyApi: err) {
                    self.controllers.goToLoginPage(view: self.view, direction: .toBottom)
                }
            }
            
            if isGetted{
                self.getViewControllers()
                self.activityIndicator.stopAnimating()
                
            }
        })
        
    }
    
    
    fileprivate func getViewControllers(){
        
        var controllersList:[UIViewController] = []
        
        let profileNavController = controllers.getControllerMain(.profileNavigationViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 1)
        
//        let excursionManagementNavViewController = controllers.getControllerMain(.excursionManagementNavigationViewController)
//        
//        excursionManagementNavViewController.tabBarItem = UITabBarItem(title: "Управление", image: UIImage(systemName: "calendar"), tag: 2)
//        
//        
//        let excursionsNavigationController = controllers.getControllerMain(.excursionsNavigationController)
//        excursionsNavigationController.tabBarItem = UITabBarItem(title: "Экскурсии", image: UIImage(systemName: "calendar"), tag: 2)
//        

//        
//        if (self.user?.getAccessLevel(rule: .isGuide) ?? false){
//            controllersList.append(excursionsNavigationController)
//        }
//        
//        
//        if (self.user?.getAccessLevel(rule: .canReadTourList) ?? false) {
//            controllersList.append(excursionManagementNavViewController)
//        }
        
//        controllersList.append(profileNavController)
        
        controllersList = [profileNavController]
        
        self.setViewControllers([profileNavController], animated: true)
        print("setViewControllers")
        
        if controllersList.count == 3{
            self.selectedIndex = 1
        }
    }
    
    fileprivate func configureActivityIndicator(){
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    public func setLoading(){
        self.loadview.setLoadUIView()
    }
    
    public func stopLoading(){
        self.loadview.removeLoadUIView()
    }
}

extension mainTabBarViewController:MainTabBarViewProtocol{
    
}