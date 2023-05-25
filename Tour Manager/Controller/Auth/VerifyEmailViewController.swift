//
//  VerifyEmailViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit

class VerifyEmailViewController: UIViewController {
    
    
    // MARK: - my Variables
    let alerts = Alert()
    
    let controllers = Controllers()
    
    var password = ""
    var email = ""
    
    // MARK: - Outlets
    
    @IBOutlet weak var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


    
    @IBAction func verifiedButtonTap(_ sender: Any) {
        logIn()
    }
    
    
    
    fileprivate func logIn(){
        ApiManagerAuth.logIn(email: email , password: password) { isLogIn, error in
            
            if error == .emailIsNotVerifyed{
                
            } else if error == .invalidEmailOrPassword{
                
                let error = self.alerts.errorAlert(.invalidEmailOrPassword)
                self.present(error, animated: true)
                
            } else if error == .unknowmError{
                
                let error = self.alerts.errorAlert(.unknown)
                self.present(error, animated: true)
                
            }
            
            if !isLogIn{ return }
            
            let token = AppDelegate.user.getToken()
                ApiManagerUserData.getUserInfo(token: token) { isInfo, error in
                    if error == .dataNotFound{
                        self.goToAddingPersonalData()
                        return
                    }else if error == .invalidToken{
                        return
                    } else if error == .tokenExpired{
                        return
                    } else if error == .unknowmError{
                        return
                    }
                    
                    if isInfo == true{
                        self.goToMainTabBar()
                    }
                }
            
        }
    }
    
    
    // MARK: - Navigation
    
    fileprivate func goToAddingPersonalData(){
        let destination = self.controllers.getControllerAuth(.choiceOfTypeAccountViewController) as! ChoiceOfTypeAccountViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    fileprivate func goToMainTabBar(){
        let mainTabBar = self.controllers.getControllerMain(.mainTabBarController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toTop
        options.duration = 0.3
        options.style = .easeIn
        
        window?.set(rootViewController: mainTabBar,options: options)
        
    }
    
}
