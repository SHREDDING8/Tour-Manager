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
    func showError(error: NetworkServiceHelper.NetworkError) {
        DispatchQueue.main.async {
            
            let errorBody = error.getAlertBody()
            
            if error == .tokenExpired ||
                error == .invalidFirebaseIdToken ||
                error == .TOKEN_EXPIRED ||
                error == .USER_DISABLED ||
                error == .USER_NOT_FOUND ||
                error == .INVALID_REFRESH_TOKEN{
                
                let alert = UIAlertController(
                    title: errorBody.title,
                    message: errorBody.msg,
                    preferredStyle: .alert
                )
                let logOut = UIAlertAction(title: "Выйти", style: .destructive) { _ in
                    MainAssembly.goToLoginPage(view: self.view)
                }
                
                alert.addAction(logOut)
                self.present(alert, animated: true)
                return
            }
            
            AlertKitAPI.present(
                title: errorBody.title,
                subtitle: errorBody.msg,
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )
        }
    }
    
    func updateControllers() {
        var controllersList:[UIViewController] = []
        
        let profile = ProfileAssembly.createProfileViewController()
        profile.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 1)
        
        let excursionManagementNavViewController = TourManadmentAssembly.createToursManadgmentViewController()
                
        excursionManagementNavViewController.tabBarItem = UITabBarItem(title: "Управление", image: UIImage(systemName: "person.3.sequence.fill"), tag: 2)
                
        let excursionsNavigationController = TourManadmentAssembly.createGuidesToursViewController()
        
        excursionsNavigationController.tabBarItem = UITabBarItem(title: "Экскурсии", image: UIImage(systemName: "calendar"), tag: 2)



        if (self.presenter?.isUserGuide() ?? false){
            controllersList.append(excursionsNavigationController)
        }


        if (self.presenter?.isUserCanReadAllTours() ?? false) {
            controllersList.append(excursionManagementNavViewController)
        }
                
        controllersList.append(profile)
        
        if self.viewControllers?.count != controllersList.count{
            self.setViewControllers(controllersList, animated: true)
            
            if controllersList.count == 3{
                self.selectedIndex = 1
            }
        }
        
    }
    
}
