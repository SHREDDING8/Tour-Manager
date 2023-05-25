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
    
    var isSignIn = false
    var confirmPasswordIndexPath:IndexPath!
    
    var tableViewPosition:CGFloat!
    
    var email:String = ""
    
    var emailTextField:UITextField!
    var firstPasswordTextField:UITextField!
    var secondPasswordTextField:UITextField!
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var logInButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogInButton()
        configureLoadUiView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isSignIn = false
        tableView.reloadData()
        addKeyboardObservers()
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
        self.logInButton.titleLabel?.font = font.getFont(name: .americanTypewriter, style: .bold, size: 20)
    }
    
    fileprivate func configureLoadUiView(){
    }
    
    fileprivate func setIsSignIn(isSignIn:Bool){
        self.isSignIn = isSignIn
        tableView.reloadRows(at: [confirmPasswordIndexPath], with: .automatic)
        
        if self.isSignIn{
            setTitleLogInButton(title: "Регистрация")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
                tableView.scrollToRow(at: confirmPasswordIndexPath, at: .top, animated: true)
            }
        }else{
            setTitleLogInButton(title: "Вход")
        }
    }
    
    fileprivate func setTitleLogInButton(title:String){
        let title = NSAttributedString(string: title ,attributes: [.font : font.getFont(name: .americanTypewriter, style: .bold, size: 20)])
        self.logInButton.setAttributedTitle(title, for: .normal)
    }
    
    // MARK: - signIn LogIn tapped
    
    @IBAction func logIn(_ sender: Any) {
        if self.isSignIn{
            self.signIn()
        }else{
            self.logIn()
        }
    }
    
    fileprivate func signIn(){
        // validate email
        if !textFieldValidation.validateEmailTextField(self.emailTextField){
            let errorAlert = alerts.errorAlert(.email)
            self.present(errorAlert, animated: true)
            return
        }
        // validate password
        if !textFieldValidation.validatePasswordsTextField(self.firstPasswordTextField, self.secondPasswordTextField){
            let errorAlert = alerts.errorAlert(.password)
            self.present(errorAlert, animated: true)
            return
        }
        
        // signIn Api
        ApiManagerAuth.signIn(email: self.emailTextField.text!, password: self.firstPasswordTextField.text!) { isSignIn, error in
            // check errors from api
            if error == .unknowmError{
                let errorAlert = self.alerts.errorAlert(.unknown)
                self.present(errorAlert, animated: true)
                return
            }
            
            self.logIn()
            
        }
    }
    
    fileprivate func logIn(){
        ApiManagerAuth.logIn(email: self.emailTextField.text!, password: self.firstPasswordTextField.text!) { isLogIn, error in
            
            if error == .emailIsNotVerifyed{
                self.goToVerifyVC()
                
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
    
    // MARK: - Reset Password Tapped
    
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        if !textFieldValidation.validateEmailTextField(emailTextField){
            let error = alerts.errorAlert(.email)
            self.present(error, animated: true)
            return
        }
        
        ApiManagerAuth.resetPassword(email: emailTextField.text!) { isSendEmail, error in
            if error == .userNotFound{
                let error = self.alerts.errorAlert(.userNotFound)
                self.present(error, animated: true)
                return
            } else if error == .unknowmError{
                let error = self.alerts.errorAlert(.unknown)
                self.present(error, animated: true)
                return
            }
            
            let alert = UIAlertController(title: "Сообщение о восстановлеии email отпправлено", message: "Проверьте почту", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(actionOk)
            self.present(alert, animated: true)
        }
        
        
    }
    
    
    // MARK: - Navigation
    
    fileprivate func goToMainTabBar(){
        let mainTabBar = self.controllers.getControllerMain(.mainTabBarController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toTop
        options.duration = 0.3
        options.style = .easeIn
        
        window?.set(rootViewController: mainTabBar,options: options)
        
    }
    
    fileprivate func goToVerifyVC(){
        let destination = self.controllers.getControllerAuth(.verifycontroller) as! VerifyEmailViewController
        destination.email = self.emailTextField.text!
        destination.password = self.firstPasswordTextField.text!
        
        self.navigationController?.pushViewController(destination, animated: true)
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
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.frame.origin.y = tableViewPosition
    }
    
}


// MARK: - UI Table View Delegate
extension LoginViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
            
            textField.restorationIdentifier = "emailTextField"
            self.emailTextField = textField
        case 1:
            textField.placeholder = "Пароль"
            label.text = "Пароль"
            textField.text = ""
            
            textField.restorationIdentifier = "passwordTextField"
            self.firstPasswordTextField = textField
        case 2:
            textField.placeholder = "Повторите пароль"
            label.text = "Повторите пароль"
            textField.text = ""
            
            textField.restorationIdentifier = "confirmPasswordTextField"
            
            self.confirmPasswordIndexPath = indexPath
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

extension LoginViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.restorationIdentifier == "emailTextField"{
            
            if !textFieldValidation.validateEmailTextField(textField){
                let errorAlert = alerts.errorAlert(.email)
                self.present(errorAlert, animated: true)
            }
            ApiManagerAuth.isUserExists(email: textField.text!) { isUserExists, error in
                if error != nil{
                    textField.resignFirstResponder()
                    var errorAlert:UIAlertController
                    switch error{
                        case .requestTimedOut:
                        errorAlert = self.alerts.errorAlert(.requestTimedOut)
                            
                    case .unknowmError:
                        errorAlert = self.alerts.errorAlert(.unknown)

                    case .none:
                        return
                    case .some(.emailIsNotVerifyed):
                        return
                    case .some(.invalidEmailOrPassword):
                        return
                    
                    case .some(.userNotFound):
                        return
                    }
                    self.present(errorAlert, animated: true)
                    return
                }
                
                self.setIsSignIn(isSignIn: !isUserExists!)
                self.email = textField.text!
                self.firstPasswordTextField.text = ""
                self.secondPasswordTextField.text = ""
                self.firstPasswordTextField.becomeFirstResponder()
            }
        } else if textField.restorationIdentifier == "passwordTextField"{
            _ = self.isSignIn ? secondPasswordTextField.becomeFirstResponder() : firstPasswordTextField.resignFirstResponder()
            self.secondPasswordTextField.text = ""
        } else{
            textField.resignFirstResponder()
        }
        return true
    }
}
