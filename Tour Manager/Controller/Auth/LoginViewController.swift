//
//  LoginViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.05.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - my variables
    
    let font = Font()
    let controllers = Controllers()
    let textFieldValidation = TextFieldValidation()
    let alerts = Alert()
    
    var user:User!
    let userDefaults = UserDefaults()
    
    var isSignIn = false
    
    var tableViewPosition:CGFloat!
    
    var email:String = ""
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureLogInButton()
        self.isSignIn = false
        tableView.reloadData()
        addKeyboardObservers()
        userDefaults.set(nil, forKey: "authToken")
        userDefaults.set(nil, forKey: "localId")
        
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
            self.logInButton.setTitle(title: "Войти", size: 20, style: .bold)
        }
    }
    
    
    
    // MARK: - Buttons Tapped
    
    @IBAction func logIn(_ sender: Any) {
        
        // validate email
        if !textFieldValidation.validateEmailTextField(self.emailTextField){
            let errorAlert = alerts.errorAlert(errorTypeFront: .email)
            self.present(errorAlert, animated: true)
            return
        }
        
        self.isSignIn ? self.signIn() :  self.logIn()
        
    }
    
    
    @IBAction func logInSignInTapped(_ sender: Any) {
        self.setIsSignIn(isSignIn: !self.isSignIn)
    }
    
    // MARK: - Reset Password Tapped
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        if !textFieldValidation.validateEmailTextField(emailTextField){
            
            let error = alerts.errorAlert(errorTypeFront: .email)
            self.present(error, animated: true)
            return
        }
        
        self.user?.setEmail(email: self.emailTextField.text ?? "")
        
        self.user?.resetPassword(completion: { isReset, error in
            if error == .userNotFound{
                let error = self.alerts.errorAlert(errorTypeApi: .userNotFound)
                self.present(error, animated: true)
                return
            } else if error == .unknowmError{
                let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(error, animated: true)
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
        if !textFieldValidation.validatePasswordsTextField(self.firstPasswordTextField, self.secondPasswordTextField){
            let errorAlert = alerts.errorAlert(errorTypeFront: .weakPassword)
            self.present(errorAlert, animated: true)
            return
        }
        
        self.user?.setEmail(email: self.email)
        
        // signIn Api
        
        self.user?.signIn(password: self.firstPasswordTextField.text!, completion: { isSignIn, error in
            if error == .unknowmError{
                let errorAlert = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(errorAlert, animated: true)
                return
            } else if error == .emailExist{
                let errorAlert = self.alerts.errorAlert(errorTypeApi: .emailExists)
                self.present(errorAlert, animated: true)
                return
            }else if error == .weakPassword{
                let errorAlert = self.alerts.errorAlert(errorTypeApi: .weakPassword)
                self.present(errorAlert, animated: true)
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
            if error == .emailIsNotVerifyed{
                self.goToVerifyVC()
                return
                
            } else if error == .invalidEmailOrPassword{
                
                let error = self.alerts.errorAlert(errorTypeApi: .invalidEmailOrPassword)
                self.present(error, animated: true)
                return
                
            } else if error == .unknowmError{
                
                let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(error, animated: true)
                return
            }
            
            self.user?.getUserInfoFromApi(completion: { isGetted, error in
                if error == .dataNotFound{
                    self.goToAddingPersonalData()
                    return
                }else if error == .invalidToken{
                    let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(error, animated: true)
                    return
                } else if error == .tokenExpired{
                    let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(error, animated: true)
                    return
                } else if error == .unknowmError{
                    let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(error, animated: true)
                    return
                }
                
                if isGetted{
                    self.controllers.goToMainTabBar(view: self.view)
                }
                
            })
        })
    }
    
   
 
    // MARK: - Navigation
        
    fileprivate func goToVerifyVC(){
        
        self.user?.sendVerifyEmail(password: self.firstPasswordTextField.text!, completion: { isSent, error in
            if error == .unknowmError{
                let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(error, animated: true)
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
            
            self.email = textField.text!
            
            self.firstPasswordTextField.text = ""
            self.secondPasswordTextField?.text = ""
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
            
            self.firstPasswordTextField.text = ""
            self.secondPasswordTextField?.text = ""
        
        }
    }
}
