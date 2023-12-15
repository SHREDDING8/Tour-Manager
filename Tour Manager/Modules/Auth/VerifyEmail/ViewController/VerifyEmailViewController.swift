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
        
        addTargets()
        
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
        self.presenter.confirmTapped()
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
    
    // MARK: - Navigation
}

extension VerifyEmailViewController:VerifyEmailViewProtocol{
    func emailVerifyed() {
        let vc = AuthAssembly.createTypeOfAccountViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        var navigationArray = navigationController?.viewControllers ?? []
        navigationArray.remove(at: (navigationArray.count) - 2)
        self.navigationController?.viewControllers = navigationArray
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
