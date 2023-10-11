//
//  LoginViewController2.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.06.2023.
//

import UIKit
import AlertKit

class LoginViewController: UIViewController {
    
    var presenter:LoginPresenterProtocol?
    // MARK: -
    var loadUIView:LoadView!
    let font = Font()
    let controllers = Controllers()
    let alerts = Alert()
                        
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
        
        addKeyboardObservers()
        
        self.presenter?.removeAllData()
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
    
    // MARK: - Buttons Tapped
    
    @IBAction func logIn(_ sender: Any) {
        presenter?.loginButtonTapped()
        
    }
    
    @IBAction func logInSignInTapped(_ sender: Any) {
        presenter?.changeSignInLoginTapped()
    }
    
    // MARK: - Reset Password Tapped
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
                
        let resetPasswordAlert = UIAlertController(title: "Сброс пароля", message: "Введите email", preferredStyle: .alert)
        
        resetPasswordAlert.addTextField { textField in
            textField.placeholder = "Email"
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let resetAction = UIAlertAction(title: "Сбросить пароль", style: .destructive) { _ in
            self.presenter?.resetPassword(email: resetPasswordAlert.textFields?.first?.text ?? "")
        }
        
        resetPasswordAlert.addAction(cancelAction)
        resetPasswordAlert.addAction(resetAction)
        
        resetAction.isEnabled = false
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: resetPasswordAlert.textFields?.first, queue: .main) { _ in
            
            resetAction.isEnabled = (self.presenter?.isValidEmail(email: resetPasswordAlert.textFields?.first?.text ?? "") ?? false)
        }
        
        self.present(resetPasswordAlert, animated: true)
        
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
        
        stackView.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.iconImageView.layer.opacity = 1
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
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField{
            self.presenter?.setEmail(email: textField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) ?? "" )
            
        }else if textField == self.firstPasswordTextField{
            self.presenter?.setPassword(password: textField.text ?? "")
            
        } else if textField == self.secondPasswordTextField{
            self.presenter?.setConfirmPassword(password: textField.text ?? "")
        }
    }
}

extension LoginViewController:LoginViewProtocol {
    
    func setLoginView(){
        self.signInLogInButton.setTitle(title: "Регистрация" , size: 16, style: .semiBold)
        self.logInButton.setTitle(title: "Войти", size: 20, style: .bold)
        
        UIView.animate(withDuration: 0.3) {
            self.secondPasswordStack.layer.opacity = 0
        }
        
        self.firstPasswordTextField.text = ""
        self.secondPasswordTextField.text = ""
    }
    
    func setSignUpView(){
        self.logInButton.setTitle(title: "Регистрация", size: 20, style: .bold)
        self.signInLogInButton.setTitle(title: "Вход" , size: 16, style: .semiBold)
        UIView.animate(withDuration: 0.3) {
            self.secondPasswordStack.layer.opacity = 1
        }
        
        self.firstPasswordTextField.text = ""
        self.secondPasswordTextField.text = ""
    }
    
    func setLoadingView(){
        self.loadUIView.setLoadUIView()
    }
    
    func hideLoadingView(){
        self.loadUIView.removeLoadUIView()
    }
    
    func resetSuccess(email:String){
        AlertKitAPI.present(title: "Сообщение отправленно на почту", subtitle: email, icon: .done, style: .iOS17AppleMusic, haptic: .success)
    }
    
    func resetFailure(email:String){
        AlertKitAPI.present(title: "Произошла ошибка", subtitle: email, icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
    func wrongEmail(){
        alerts.validationStringError(self, title: "Неправильный email", message: "Проверьте правильность введенных данных и повторите попытку")
    }
    
    func wrongEmailOrPassword(){
        self.alerts.errorAlert(self, errorTypeApi: .invalidEmailOrPassword)
    }
    
    func passwordsNotValid(){
        self.alerts.errorAlert(self, errorTypeApi: .weakPassword)
    }
    
    func passwordsAreNotEqual(){
        self.alerts.errorAlert(self, errorTypeApi: .passwordsAreNotEqual)
    }
    
    func unknownError(){
        AlertKitAPI.present(title: "Неизвестная ошибка", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
    func goToVerifyVC(email:String, password:String){
        
        let destination = self.controllers.getControllerAuth(.verifycontroller) as! VerifyEmailViewController
        
        destination.email = email
        destination.password = password
        
        self.navigationController?.pushViewController(destination, animated: true)
        
    }
    
    func goToAddingPersonalData(){
        let destination = self.controllers.getControllerAuth(.choiceOfTypeAccountViewController) as! ChoiceOfTypeAccountViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func goToMain(){
        self.controllers.goToMainTabBar(view: self.view, direction: .fade)
    }
    
    func verifySendError(){
        AlertKitAPI.present(title: "Ошибка при отправке сообщения", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
    func emailExist(){
        AlertKitAPI.present(title: "Такой Email уже сушествует", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
}
