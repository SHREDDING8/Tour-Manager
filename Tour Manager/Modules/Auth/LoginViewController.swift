//
//  LoginViewController2.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.06.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    var presenter:LoginPresenterProtocol?
    // MARK: -
    var loadUIView:LoadView!
    let font = Font()
    let controllers = Controllers()
    let validation = StringValidation()
    let alerts = Alert()
    
    let localNotifications = LocalNotifications()
            
    var isSignIn = false
        
    var stackViewPoint:Double = 0
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    @IBOutlet var emailTextField:UITextField!
    @IBOutlet var firstPasswordTextField:UITextField!
    @IBOutlet var secondPasswordTextField:UITextField!
    
    
    @IBOutlet weak var secondPasswordStack: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var signInLogInButton: UIButton!
    
    override func loadView() {
        super.loadView()
        let presenter = LoginPresenter(view: self)
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.loadUIView = LoadView(viewController: self)
        
        self.secondPasswordStack.layer.opacity = 0
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        configureLogInButton()
        self.isSignIn = false
        addKeyboardObservers()
        
        self.presenter?.removeAllData()
        
        localNotifications.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stackViewPoint = stackView.frame.origin.y
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    fileprivate func configureLogInButton(){
        self.logInButton.setTitle(title: "Войти", size: 20, style: .bold)
    }
    
    fileprivate func setIsSignIn(isSignIn:Bool){
        self.isSignIn = isSignIn
        
        self.firstPasswordTextField.text = ""
        self.secondPasswordTextField.text = ""
        
        if self.isSignIn{
            self.logInButton.setTitle(title: "Регистрация", size: 20, style: .bold)
            self.signInLogInButton.setTitle(title: "Вход" , size: 16, style: .semiBold)
            UIView.animate(withDuration: 0.3) {
                self.secondPasswordStack.layer.opacity = 1
            }
        }else{
            self.signInLogInButton.setTitle(title: "Регистрация" , size: 16, style: .semiBold)
            self.logInButton.setTitle(title: "Войти", size: 20, style: .bold)
            
            UIView.animate(withDuration: 0.3) {
                self.secondPasswordStack.layer.opacity = 0
            }
        }
    }
    
    
    // MARK: - Buttons Tapped
    
    @IBAction func logIn(_ sender: Any) {
        
        self.loadUIView.setLoadUIView()
       
        // validate email
        if !validation.validateEmail(self.emailTextField.text ?? ""){
            alerts.validationStringError(self, title: "Неправильный email", message: "Проверьте правильность введенных данных и повторите попытку")
            self.loadUIView.removeLoadUIView()
            return
        }
        print("logIn")
        self.isSignIn ? self.signIn() :  self.logIn()
        
    }
    
    @IBAction func logInSignInTapped(_ sender: Any) {
        self.setIsSignIn(isSignIn: !self.isSignIn)
    }
    
    
    // MARK: - Reset Password Tapped
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        
        self.loadUIView.setLoadUIView()
        
        if !self.emailTextField.hasText{
            self.alerts.validationStringError(self, title: "Поле email пустое", message: "Введите email")
            self.loadUIView.removeLoadUIView()
            return
        }
        
        if !validation.validateEmail(self.emailTextField.text ?? ""){
            alerts.validationStringError(self, title: "Неправильный email", message: "Проверьте правильность введенных данных и повторите попытку")
            self.loadUIView.removeLoadUIView()
            return
        }
        
        self.presenter?.resetPassword(email: self.emailTextField.text ?? "", completion: { isReset, error in
            
                self.loadUIView.removeLoadUIView()
            
            if error == .userNotFound{
                self.alerts.errorAlert(self, errorTypeApi: .userNotFound)
                return
            } else if error == .unknowmError{
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
                return
            }
            
            if isReset{
                let alert =  self.alerts.infoAlert(title: "Email о восстановлеини аккаунта отправлен вам на почту", meesage: nil)
                self.present(alert, animated: true)
            }else{
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
                return
            }
            
        })
        
    }
    
    
    // MARK: - Sign In
    
    fileprivate func signIn(){
        // validate password
        if !validation.validatePasswordsString(self.firstPasswordTextField.text ?? "", self.secondPasswordTextField.text ?? ""){
            let errorAlert = alerts.errorAlert(errorTypeFront: .weakPassword)
            self.present(errorAlert, animated: true)
            self.loadUIView.removeLoadUIView()
            return
        }
    
        // signUp Api
        
        self.presenter?.signUp(email: self.emailTextField.text ?? "", password: self.firstPasswordTextField.text ?? "", completion: { isSignIn, error in
            
            if !isSignIn{ self.loadUIView.removeLoadUIView() }
            
            if error == .unknowmError{
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
                return
            } else if error == .emailExist{
                self.alerts.errorAlert(self, errorTypeApi: .emailExists)
                return
            }else if error == .weakPassword{
                self.alerts.errorAlert(self, errorTypeApi: .weakPassword)
                return
            }
            if isSignIn{
                self.logIn()
            }
            
        })
              
    }
    
    
    
    // MARK: - logIn
    
    fileprivate func logIn(){
        
        self.presenter?.logIn(email: self.emailTextField.text ?? "",password: self.firstPasswordTextField.text ?? "", completion: { isLogIn, error in
            
            if !isLogIn{ self.loadUIView.removeLoadUIView() }
            
            if error == .emailIsNotVerifyed{
                self.goToVerifyVC()
                return
                
            } else if error == .invalidEmailOrPassword{
                
                self.alerts.errorAlert(self, errorTypeApi: .invalidEmailOrPassword)
                return
                
            } else if error == .unknowmError{
                self.alerts.errorAlert(self, errorTypeApi: .unknown)
                return
            } else if error == .notConnected{
                self.controllers.goToLoginPage(view: self.view, direction: .fade)
            }
            
            
            
            self.presenter?.getUserInfoFromApi(completion: { isGetted, error in
                
                if !isGetted{ self.loadUIView.removeLoadUIView() }
                
                if error == .dataNotFound{
                    self.goToAddingPersonalData()
                    return
                }
                
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err)
                    return
                }
                
                if isGetted{
                    self.loadUIView.removeLoadUIView()
                    print("goToMainTabBar")
                    self.controllers.goToMainTabBar(view: self.view, direction: .toBottom)
                }
                
            })
        })
    }
    
    
    
    
       // MARK: - Navigation
           
       fileprivate func goToVerifyVC(){
           
           self.presenter?.sendVerifyEmail(email:self.emailTextField.text ?? "", password: self.firstPasswordTextField.text ?? "", completion: { isSent, error in
               if error == .unknowmError{
                   self.alerts.errorAlert(self, errorTypeApi: .unknown)
                   return
               }
               
               if isSent{
                   let destination = self.controllers.getControllerAuth(.verifycontroller) as! VerifyEmailViewController
                   destination.email = self.emailTextField.text!
                   destination.password = self.firstPasswordTextField.text!
                   
                   self.navigationController?.pushViewController(destination, animated: true)
               }
           })
       }
       
    
    fileprivate func goToAddingPersonalData(){
        let destination = self.controllers.getControllerAuth(.choiceOfTypeAccountViewController) as! ChoiceOfTypeAccountViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    
    // MARK: - keyboard
    
    fileprivate func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){

        if let _ = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if Int(stackView.frame.origin.y) != Int(self.iconImageView.frame.origin.y - 10){
                
                stackView.transform = CGAffineTransform(translationX: 0, y: -abs(self.iconImageView.frame.origin.y - 10 - stackView.frame.origin.y))
                
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.layer.opacity = 0
                }
            }
            
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.firstPasswordTextField.isFirstResponder || self.secondPasswordTextField.isFirstResponder{
            stackView.transform = CGAffineTransform(translationX: 0, y: 0)
            
            UIView.animate(withDuration: 0.3) {
                self.iconImageView.layer.opacity = 1
            }
        }
        
        
    }
        
}


extension LoginViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.secondPasswordTextField{
            textField.isSecureTextEntry = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField{
            self.firstPasswordTextField.text = ""
            self.secondPasswordTextField?.text = ""
            self.firstPasswordTextField.becomeFirstResponder()

        } else if textField == firstPasswordTextField{
            self.secondPasswordTextField?.text = ""
            _ = self.isSignIn ? secondPasswordTextField?.becomeFirstResponder() : firstPasswordTextField.resignFirstResponder()
           
        } else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.presenter?.setEmail(email: emailTextField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) ?? "" )
        self.presenter?.setPassword(password: self.firstPasswordTextField.text ?? "")
        self.presenter?.setConfirmPassword(password: self.secondPasswordTextField.text ?? "")
        
        if textField == emailTextField{
            
            self.firstPasswordTextField.text = ""
            self.secondPasswordTextField?.text = ""
            self.presenter?.setPassword(password: "")
            self.presenter?.setConfirmPassword(password: "")
        
        }else if textField == self.firstPasswordTextField{
            self.presenter?.setPassword(password: textField.text ?? "")
        } else if textField == self.secondPasswordTextField{
            self.presenter?.setConfirmPassword(password: textField.text ?? "")
        }
    }
    
}

extension LoginViewController:LoginViewProtocol {
    
}
