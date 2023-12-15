//
//  VerifyEmailViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit
import AlertKit

class VerifyEmailViewController: BaseViewController {
    var presenter:VerifyEmailPresenterProtocol!
    
    private func view() -> VerifyEmailView{
        return view as! VerifyEmailView
    }
    
    override func loadView() {
        super.loadView()
        self.view = VerifyEmailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view().email.text = presenter.loginData.email
        self.titleString = "Подтверждение email"
        self.setBackButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTimerSetEmailAgain()
    }
    
    private func addTargets(){
        self.view().sendAgain.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        self.view().confirmed.addTarget(self, action: #selector(confirmedTapped), for: .touchUpInside)
    }
    
    @objc func resendTapped(){
        self.presenter.sendVerifyEmail()
    }
    
    @objc func confirmedTapped(){
        
    }
    
    fileprivate func setTimerSetEmailAgain(){
        var time = 60
        self.view().sendAgain.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.view().sendAgain.setTitle(title: "Отправить повторно через \(time)", size: 12, style: .regular)
            time -= 1
            if time == 0{
                self.view().sendAgain.setTitle(title: "Отправить повторно", size: 12, style: .regular)
                self.view().sendAgain.isEnabled = true
                timer.invalidate()
            }
        }
    }
    
    @IBAction func verifiedButtonTap(_ sender: Any) {
        self.logIn()
    }
    
    @IBAction func resendEmail(_ sender: Any) {
        
//        self.presenter?.sendVerifyEmail(email: self.email, password: self.password, completion: { isSent, error in
//            self.loadUIView.removeLoadUIView()
//            if error == .unknowmError{
//                self.alerts.errorAlert(self, errorTypeApi: .unknown)
//            }
//            
//            else{
//                self.setTimerSetEmailAgain()
//                let alert = self.alerts.infoAlert(title: "Email Отправлен", meesage: "Проверьте почту и подтвердите аккаунт")
//                self.present(alert, animated: true)
//            }
//           
//        })
    }
    
    fileprivate func logIn(){
        
//        self.presenter?.logIn(email: self.email, password: password, completion: { isLogIn, error in
//            if error == .emailIsNotVerifyed{
//                
//            } else if error == .invalidEmailOrPassword{
//                
//                self.alerts.errorAlert(self, errorTypeApi: .unknown)
//                
//            } else if error == .unknowmError{
//                
//                self.alerts.errorAlert(self, errorTypeApi: .unknown)
//                
//            }else if error == .notConnected{
//                self.controllers.goToLoginPage(view: self.view, direction: .fade)
//                return
//            }
//            
//            if !isLogIn{
//                self.loadUIView.removeLoadUIView()
//                return
//            }
//            
////            self.presenter?.getUserInfoFromApi(completion: { isInfo, error in
////                
////                if error == .dataNotFound{
////                    self.goToAddingPersonalData()
////                    self.loadUIView.removeLoadUIView()
////                    return
////                }
////                
////                if let err = error{
////                    self.alerts.errorAlert(self, errorUserDataApi: err) {
////                        self.loadUIView.removeLoadUIView()
////                        self.goToLogInPage()
////                    }
////                }
////                
////                if isInfo{
////                    self.loadUIView.removeLoadUIView()
////                    self.goToMainTabBar()
////                }
////            })
//            
//        })
    }
    
    
    // MARK: - Navigation
    
    fileprivate func goToAddingPersonalData(){
//        let destination = self.controllers.getControllerAuth(.choiceOfTypeAccountViewController) as! ChoiceOfTypeAccountViewController
        
//        self.navigationController?.pushViewController(destination, animated: true)
        var navigationArray = navigationController?.viewControllers ?? []
        navigationArray.remove(at: (navigationArray.count) - 2)
        self.navigationController?.viewControllers = navigationArray
    }
    
    fileprivate func goToMainTabBar(){
        MainAssembly.goToMainTabBar(view: self.view)
    }
}

extension VerifyEmailViewController:VerifyEmailViewProtocol{
    func emailVerifyed() {
        
    }
    
    func goToMain() {
        MainAssembly.goToMainTabBar(view: self.view)
    }
    
    func emailSended() {
        AlertKitAPI.present(
            title: "Письмо отправлено",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        
        self.setTimerSetEmailAgain()
    }
    
}
