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
    let font = Font()
    
    let user = AppDelegate.user
    
    
    var password = ""
    var email = ""
    
    // MARK: - Outlets
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var emailSentToEmailLabel: UILabel!
    
    @IBOutlet weak var sendEmailAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTimerSetEmailAgain()
    }
    
    // MARK: - ConfigurationView
    
    fileprivate func configureView(){
        self.emailSentToEmailLabel.text = "Сообщение отправлено на \(self.email)"
        
        self.setTitleResend(value: "Повторно отправить подтверждение через 60")
        self.sendEmailAgainButton.titleLabel?.textAlignment = .center
        
    }
    
    
    
    fileprivate func setTimerSetEmailAgain(){
        var time = 60
        self.sendEmailAgainButton.isUserInteractionEnabled = false
        self.sendEmailAgainButton.layer.opacity = 0.5
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.setTitleResend(value: "Повторно отправить подтверждение через \(time)")
            time -= 1
            if time == 0{
                self.setTitleResend(value: "Повторно отправить подтверждение")
                self.sendEmailAgainButton.layer.opacity = 1
                self.sendEmailAgainButton.isUserInteractionEnabled = true
                timer.invalidate()
            }
        }
    }
    
    fileprivate func setTitleResend(value:String){
        let fontButton = font.getFont(name: .americanTypewriter, style: .semiBold, size: 16)
        
        self.sendEmailAgainButton.titleLabel?.font = fontButton
        self.sendEmailAgainButton.setTitle(value, for: .normal)
    }


    
    @IBAction func verifiedButtonTap(_ sender: Any) {
        logIn()
    }
    
    @IBAction func resendEmail(_ sender: Any) {
        
        self.user?.sendVerifyEmail(password: self.password, completion: { isSent, error in
            if error == .unknowmError{
                let alert = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(alert, animated: true)
            }else{
                let alert = UIAlertController(title: "Email Отправлен", message: "Проверьте почту и подтвердите аккаунт", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                self.setTimerSetEmailAgain()
                
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            }
        })
    }
    
    fileprivate func logIn(){
        
        self.user?.logIn(password: password, completion: { isLogIn, error in
            if error == .emailIsNotVerifyed{
                
            } else if error == .invalidEmailOrPassword{
                
                let error = self.alerts.errorAlert(errorTypeApi: .invalidEmailOrPassword)
                self.present(error, animated: true)
                
            } else if error == .unknowmError{
                
                let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(error, animated: true)
                
            }
            
            if !isLogIn{ return }
            
            self.user?.getUserInfoFromApi(completion: { isInfo, error in
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
            })
            
        })
    }
    
    
    // MARK: - Navigation
    
    fileprivate func goToAddingPersonalData(){
        let destination = self.controllers.getControllerAuth(.choiceOfTypeAccountViewController) as! ChoiceOfTypeAccountViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
        var navigationArray = navigationController?.viewControllers ?? []
        navigationArray.remove(at: (navigationArray.count) - 2)
        self.navigationController?.viewControllers = navigationArray
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
