//
//  LoginViewController2.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.06.2023.
//

import UIKit
import AlertKit

class Login2ViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.presenter?.removeAllData()
    }
        
    // MARK: - Buttons Tapped
    
    @IBAction func logIn(_ sender: Any) {
        print("logIn")
        presenter?.loginButtonTapped()
        
    }
    
    @IBAction func logInSignInTapped(_ sender: Any) {
//        presenter?.changeSignInLoginTapped()
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
}

extension Login2ViewController:UITextFieldDelegate{
    
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

extension Login2ViewController:LoginViewProtocol {
    func goToVerifyVC(loginData: loginData) {
        
    }
    
    func emailIsNotVerifyed() {
        
    }
    
    func modeChanged(newMode: LoginPresenter.PageModes) {
        
    }
    
    func setUpdating() {
        
    }
    
    func stopUpdating() {
        
    }
    
    func setLoading() {
        
    }
    
    func stopLoading() {
        
    }
    
    func setSaving() {
        
    }
    
    func stopSaving() {
        
    }
    
    func showLoadingView() {
        
    }
    
    func stopLoadingView() {
        
    }
    
    func showError(error: NetworkServiceHelper.NetworkError) {
        
    }
    
    
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
                
        self.navigationController?.pushViewController(destination, animated: true)
        
    }
    
    func goToAddingPersonalData(){
        let destination = self.controllers.getControllerAuth(.choiceOfTypeAccountViewController) as! TypeAccountViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func goToMain(){
        MainAssembly.goToMainTabBar(view: self.view)
    }
    
    func verifySendError(){
        AlertKitAPI.present(title: "Ошибка при отправке сообщения", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
    func emailExist(){
        AlertKitAPI.present(title: "Такой Email уже сушествует", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
}
