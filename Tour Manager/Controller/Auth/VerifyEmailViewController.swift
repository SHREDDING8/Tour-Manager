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
    
    let user = AppDelegate.user!
    
    let apiAuth = ApiManagerAuth()
    let apiUserData = ApiManagerUserData()
    
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
    
    @IBAction func resendEmail(_ sender: Any) {
        apiAuth.sendVerifyEmail(email: self.email, password: self.password) { isSent, error in
            if error == .unknowmError{
                let alert = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(alert, animated: true)
            }else{
                let alert = UIAlertController(title: "Email Отправлен", message: "Проверьте почту и подтвердите аккаунт", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    
    
    fileprivate func logIn(){
        apiAuth.logIn(email: email , password: password) { isLogIn, error in
            
            if error == .emailIsNotVerifyed{
                
            } else if error == .invalidEmailOrPassword{
                
                let error = self.alerts.errorAlert(errorTypeApi: .invalidEmailOrPassword)
                self.present(error, animated: true)
                
            } else if error == .unknowmError{
                
                let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(error, animated: true)
                
            }
            
            if !isLogIn{ return }
            
            let token = self.user.getToken()
            self.apiUserData.getUserInfo(token: token) { isInfo, error in
                    if error == .dataNotFound{
                        self.goToAddingPersonalData()
                        return
                    }else if error == .invalidToken{
                        print("invalidToken")
                        self.goToLogInPage()
                    } else if error == .tokenExpired{
                        print("tokenExpired")
                        self.goToLogInPage()
                    } else if error == .unknowmError{
                        print("unknowmError")
                        self.goToLogInPage()
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
    fileprivate func goToLogInPage(){
        print("goToLogInPage")
        let mainLogIn = self.controllers.getControllerAuth(.mainAuthController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toBottom
        options.duration = 0.3
        options.style = .easeIn
        
        window?.set(rootViewController: mainLogIn,options: options)
        
    }
    
}
