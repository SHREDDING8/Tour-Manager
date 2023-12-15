//
//  LoginViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 13.12.2023.
//

import UIKit
import AlertKit

class LoginViewController: BaseViewController {
    
    var presenter:LoginPresenterProtocol!
    
    private func view() -> LoginView{
        return view as! LoginView
    }
    
    override func loadView() {
        super.loadView()
        self.view = LoginView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleString = "Вход"
        addDelegates()
        addTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.removeAllData()
    }
    
    func addDelegates(){
        self.view().email.textField.delegate = self
        self.view().password.textField.delegate = self
        self.view().confirmPassword.textField.delegate = self
    }
    
    func addTargets(){
        self.view().changeModeButton.addTarget(self, action: #selector(changeModeButtonTapped), for: .touchUpInside)
        
        self.view().forgotPassword.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        
        self.view().logInButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        self.view().email.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEditingEvents)
        self.view().password.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEditingEvents)
        self.view().confirmPassword.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEditingEvents)
    }
    
    
    // MARK: - Targets
    @objc private func changeModeButtonTapped(){
        presenter.changeMode()
    }
    
    @objc private func forgotPasswordTapped(){
        let resetPasswordAlert = UIAlertController(title: "Сброс пароля", message: "Введите email", preferredStyle: .alert)
        
        resetPasswordAlert.addTextField { textField in
            textField.placeholder = "Email"
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let resetAction = UIAlertAction(title: "Сбросить пароль", style: .destructive) { _ in
            self.presenter.resetPassword(email: resetPasswordAlert.textFields?.first?.text ?? "")
        }
        
        resetPasswordAlert.addAction(cancelAction)
        resetPasswordAlert.addAction(resetAction)
        
        resetAction.isEnabled = false
        
        resetPasswordAlert.textFields?.first?.addAction(UIAction(handler: { _ in
            resetAction.isEnabled = (self.presenter.isValidEmail(email: resetPasswordAlert.textFields?.first?.text ?? ""))
        }), for: .editingChanged)
                
        self.present(resetPasswordAlert, animated: true)
    }
    
    @objc private func loginButtonTapped(){
        presenter.loginButtonTapped()
    }
    
}


extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.view().confirmPassword.textField{
            textField.isSecureTextEntry = true
        }
        return true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        switch textField.restorationIdentifier{
        case "email":
            self.presenter.setEmail(email: textField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) ?? "" )
        case "password":
            self.presenter.setPassword(password: textField.text ?? "")
        case "secondNewPassword":
            self.presenter.setConfirmPassword(password: textField.text ?? "")
        default: break
            
        }
    }
}

extension LoginViewController: LoginViewProtocol{
    func emailIsNotVerifyed() {
        self.presenter.sendVerifyEmail()
    }
    
    func modeChanged(newMode: LoginPresenter.PageModes) {
        switch newMode {
        case .login:
            self.view().confirmPassword.isHidden = true
            self.view().logInButton.setTitle(title: "Войти", size: 16, style: .regular)
            self.view().changeModeButton.setTitle(title: "Регистрация", size: 12, style: .regular)
            self.titleString = "Вход"
        case .signUp:
            self.view().confirmPassword.isHidden = false
            self.view().logInButton.setTitle(title: "Создать аккаунт", size: 16, style: .regular)
            self.view().changeModeButton.setTitle(title: "Вход", size: 12, style: .regular)
            self.titleString = "Регистрация"
            
        }
        self.view().password.textField.text = ""
        self.view().confirmPassword.textField.text = ""
    }
    
    func resetSuccess(email: String) {
        AlertKitAPI.present(
            title: "Письмо отправленно на почту",
            subtitle: email,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
        
    func wrongEmail() {
        AlertKitAPI.present(
            title: "Ненправильно введен email",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func passwordsNotValid() {
        AlertKitAPI.present(
            title: "Слабый пароль",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func passwordsAreNotEqual() {
        AlertKitAPI.present(
            title: "Пароли не совпадают",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    func goToVerifyVC(loginData:loginData) {
        AlertKitAPI.present(
            title: "Письмо отправленно на почту",
            subtitle: loginData.email,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        
        let vc = AuthAssembly.createVerifyEmailViewController(loginModel: loginData)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToMain() {
        MainAssembly.goToMainTabBar(view: self.view)
    }
    
    func goToAddingPersonalData() {
        
    }
    
    
}

