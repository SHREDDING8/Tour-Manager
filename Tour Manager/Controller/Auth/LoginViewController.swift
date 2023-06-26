//
//  LoginViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.05.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - my variables
    var loadUIView:LoadView!
    let font = Font()
    let controllers = Controllers()
    let validation = StringValidation()
    let alerts = Alert()
    
    var user:User!
    
    let userDefaults = WorkWithUserDefaults()
    
    var isSignIn = false
    
    var tableViewPosition:CGFloat!
    
    var email:String = ""
    var firstPassword = ""
    var secondPassword = ""
    
    var emailTextField:UITextField!
    var firstPasswordTextField:UITextField!
    var secondPasswordTextField:UITextField!
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var signInLogInButton: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.user = User()
        self.user = AppDelegate.user
        
        self.loadUIView = LoadView(viewController: self)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureLogInButton()
        self.isSignIn = false
        tableView.reloadData()
        addKeyboardObservers()
        
        self.userDefaults.removeLoginData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewPosition = tableView.frame.origin.y
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - configuration
    
    fileprivate func configureLogInButton(){
        self.logInButton.setTitle(title: "Войти", size: 20, style: .bold)
    }
    
    
    fileprivate func setIsSignIn(isSignIn:Bool){
        self.isSignIn = isSignIn
        
        tableView.reloadData()
        
        
        if self.isSignIn{
            self.logInButton.setTitle(title: "Регистрация", size: 20, style: .bold)
            self.signInLogInButton.setTitle(title: "Вход" , size: 16, style: .semiBold)
        }else{
            self.signInLogInButton.setTitle(title: "Регистрация" , size: 16, style: .semiBold)
            self.logInButton.setTitle(title: "Войти", size: 20, style: .bold)
        }
    }
    
    
    
    // MARK: - Buttons Tapped
    
    @IBAction func logIn(_ sender: Any) {
        
        self.loadUIView.setLoadUIView()
       
        // validate email
        if !validation.validateEmail(self.email){
            alerts.validationStringError(self, title: "Неправильный email", message: "Проверьте правильность введенных данных и повторите попытку")
            self.loadUIView.removeLoadUIView()
            return
        }
        
        self.isSignIn ? self.signIn() :  self.logIn()
        
    }
    
    
    @IBAction func logInSignInTapped(_ sender: Any) {
        self.setIsSignIn(isSignIn: !self.isSignIn)
    }
    
    // MARK: - Reset Password Tapped
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        
        self.loadUIView.setLoadUIView()
        
        if self.email.isEmpty{
            self.alerts.validationStringError(self, title: "Поле email пустое", message: "Введите email")
            self.loadUIView.removeLoadUIView()
            return
        }
        
        if !validation.validateEmail(self.email){
            alerts.validationStringError(self, title: "Неправильный email", message: "Проверьте правильность введенных данных и повторите попытку")
            self.loadUIView.removeLoadUIView()
            return
        }
        
        self.user?.setEmail(email: self.email)
        
        self.user?.resetPassword(completion: { isReset, error in
            
            if isReset{
                self.loadUIView.removeLoadUIView()
            }
            
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
            }
        })
        
    }
    
    
    
    // MARK: - Sign In
    
    fileprivate func signIn(){
        // validate password
        if !validation.validatePasswordsString(self.firstPassword, self.secondPassword){
            let errorAlert = alerts.errorAlert(errorTypeFront: .weakPassword)
            self.present(errorAlert, animated: true)
            self.loadUIView.removeLoadUIView()
            return
        }

        self.user?.setEmail(email: self.email)
    
        // signIn Api
        
        self.user?.signIn(password: self.firstPasswordTextField.text!, completion: { isSignIn, error in
            
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
        
        self.user?.setEmail(email: self.email)
        
        
        self.user?.logIn(password: self.firstPasswordTextField.text!, completion: { isLogIn, error in
            
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
            }
            
            self.user?.getUserInfoFromApi(completion: { isGetted, error in
                
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
                    self.controllers.goToMainTabBar(view: self.view, direction: .toBottom)
                }
                
            })
        })
    }
    
   
 
    // MARK: - Navigation
        
    fileprivate func goToVerifyVC(){
        
        self.user?.sendVerifyEmail(password: self.firstPasswordTextField.text!, completion: { isSent, error in
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
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.origin.y - tableView.frame.origin.y  < 125{
                tableView.frame.origin.y = self.iconImageView.frame.origin.y - 10
                UIView.animate(withDuration: 0.3) {
                    self.iconImageView.layer.opacity = 0
                }
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.frame.origin.y = tableViewPosition
        
        UIView.animate(withDuration: 0.3) {
            self.iconImageView.layer.opacity = 1
        }
        
    }
    
}


// MARK: - UI Table View Delegate
extension LoginViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSignIn ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath)
        
        // lock or unlock scroll
        cell.frame.height * 3 < tableView.frame.height ? lockScroll() : unlockScroll()
        
        // set confirm password
        
        let textField = cell.viewWithTag(2) as! UITextField
        let label = cell.viewWithTag(1) as! UILabel
        
        switch indexPath.row{
        case 0:
            textField.placeholder = "Email"
            label.text = "Email"
            textField.text = email
            
            textField.textContentType = .username
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .done
            textField.isSecureTextEntry = false
            textField.clearButtonMode = .whileEditing
            
            textField.restorationIdentifier = "emailTextField"
            self.emailTextField = textField
        case 1:
            textField.placeholder = "Пароль"
            label.text = "Пароль"
            textField.text = ""
            
            textField.textContentType = isSignIn ? .newPassword : .password
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.isSecureTextEntry = true
            
            textField.restorationIdentifier = "passwordTextField"
            
            self.firstPasswordTextField = textField
        case 2:
            textField.placeholder = "Повторите пароль"
            label.text = "Повторите пароль"
            textField.text = ""
            
            textField.textContentType = .newPassword
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.isSecureTextEntry = true
            
            textField.restorationIdentifier = "confirmPasswordTextField"
            
            self.secondPasswordTextField = textField
            
            cell.isHidden = true
            
            if self.isSignIn{
                cell.layer.opacity = 0
                cell.isHidden = false
                UIView.animate(withDuration: 0.5, delay: 0) {
                    cell.layer.opacity = 1
                }
            }
        default:
            break
        }
        
        return cell
    }
    
    fileprivate func lockScroll(){
        tableView.isScrollEnabled = false
    }
    fileprivate func unlockScroll(){
        tableView.isScrollEnabled = true
    }
}


// MARK: - UITextFieldDelegate
extension LoginViewController:UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.restorationIdentifier == "emailTextField"{
            self.firstPasswordTextField.becomeFirstResponder()

        } else if textField.restorationIdentifier == "passwordTextField"{
            _ = self.isSignIn ? secondPasswordTextField?.becomeFirstResponder() : firstPasswordTextField.resignFirstResponder()
            self.secondPasswordTextField?.text = ""
        } else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if textField.restorationIdentifier == "emailTextField"{
            
            self.email = textField.text!.trimmingCharacters(in: CharacterSet(charactersIn: " "))
            self.user.setEmail(email: self.email)
            self.emailTextField.text = self.email
            
            self.firstPasswordTextField.text = ""
            self.secondPasswordTextField?.text = ""
            self.firstPassword = ""
            self.secondPassword = ""
        
        }else if textField.restorationIdentifier == "passwordTextField"{
            self.firstPassword = textField.text!
        } else if textField.restorationIdentifier == "confirmPasswordTextField"{
            self.secondPassword = textField.text!
        }
    }
}
