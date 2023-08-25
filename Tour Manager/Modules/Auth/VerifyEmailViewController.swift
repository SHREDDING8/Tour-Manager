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
    
    var loadUIView:LoadView!
    
    var presenter:VerifyEmailPresenterProtocol?
    
    
    var password = ""
    var email = ""
    
    // MARK: - Outlets
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var emailSentToEmailLabel: UILabel!
    
    @IBOutlet weak var sendEmailAgainButton: UIButton!
    
    override func loadView() {
        super.loadView()
        self.presenter = VerifyEmailPresenter(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        self.loadUIView = LoadView(viewController: self)
        
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
        self.sendEmailAgainButton.setTitle(title: value, size: 16, style: .semiBold)
    }


    
    @IBAction func verifiedButtonTap(_ sender: Any) {
        self.loadUIView.setLoadUIView()
        self.logIn()
    }
    
    @IBAction func resendEmail(_ sender: Any) {
        self.loadUIView.setLoadUIView()
        
        self.presenter?.sendVerifyEmail(email: self.email, password: self.password, completion: { isSent, error in
            self.loadUIView.removeLoadUIView()
            if error == .unknowmError{
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
            }
            
            else{
                self.setTimerSetEmailAgain()
                let alert = self.alerts.infoAlert(title: "Email Отправлен", meesage: "Проверьте почту и подтвердите аккаунт")
                self.present(alert, animated: true)
            }
           
        })
    }
    
    fileprivate func logIn(){
        
        self.presenter?.logIn(email: self.email, password: password, completion: { isLogIn, error in
            if error == .emailIsNotVerifyed{
                
            } else if error == .invalidEmailOrPassword{
                
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
                
            } else if error == .unknowmError{
                
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
                
            }else if error == .notConnected{
                self.controllers.goToLoginPage(view: self.view, direction: .fade)
                return
            }
            
            if !isLogIn{
                self.loadUIView.removeLoadUIView()
                return
            }
            
            self.presenter?.getUserInfoFromApi(completion: { isInfo, error in
                
                if error == .dataNotFound{
                    self.goToAddingPersonalData()
                    self.loadUIView.removeLoadUIView()
                    return
                }
                
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err) {
                        self.loadUIView.removeLoadUIView()
                        self.goToLogInPage()
                    }
                }
                
                if isInfo{
                    self.loadUIView.removeLoadUIView()
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
        let mainLogIn = self.controllers.getControllerAuth(.mainAuthController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toBottom
        options.duration = 0.3
        options.style = .easeIn
        
        window?.set(rootViewController: mainLogIn,options: options)
        
    }
    
}

extension VerifyEmailViewController:VerifyEmailViewProtocol{
    
}
