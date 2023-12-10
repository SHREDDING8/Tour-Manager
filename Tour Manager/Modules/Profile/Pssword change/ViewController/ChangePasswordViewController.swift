//
//  ChangePasswordViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

class ChangePasswordViewController: UIViewController{
    
    // MARK: - My variables
    var presenter:ChangePasswordPresenterProtocol!
    
    let alerts = Alert()
    
    let controllers = Controllers()
    
    
    let stringValidation = StringValidation()
    
    
    var stackViewPosition:CGFloat!
    
    
    // MARK: - Outlets
    
    private func view() -> ChangePasswordView{
        return view as! ChangePasswordView
    }
    
    override func loadView() {
        super.loadView()
        self.view = ChangePasswordView()
    }

    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDelegates()
        
        self.addKeyboardObservers()
        self.configureView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stackViewPosition = self.view().passwordsStack.frame.origin.y
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addDelegates(){
        self.view().oldPassword.textField.delegate = self
        self.view().newPassword.textField.delegate = self
        self.view().confirmPassword.textField.delegate = self
    }
    
    
    // MARK: - Configuration
    
    fileprivate func configureView(){
        self.navigationItem.title = "Изменить пароль"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

    }
    
    // MARK: - keyboard
    
    fileprivate func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){
        
//        notification.userInf
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if keyboardSize.origin.y - tableView.frame.origin.y  < 140{
//                tableView.frame.origin.y = self.iconImageView.frame.origin.y - 10
//                
//                UIView.animate(withDuration: 0.3, delay: 0) {
//                    self.iconImageView.layer.opacity = 0
//                }
//            }
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let position = stackViewPosition{
//            tableView.frame.origin.y = position
        }
        
        UIView.animate(withDuration: 0.3, delay: 0) {
//            self.iconImageView.layer.opacity = 1
        }
    }

    

    

    
    // MARK: - Actions
    
    @IBAction func changePassword(_ sender: Any) {
//        if stringValidation.validatePasswordsString(self.passwords["newPassword"] ?? "", self.passwords["secondNewPassword"] ?? ""){
//            
//            self.presenter.updatePassword(oldPassword: self.passwords["oldPassword"] ?? "", newPassword: self.passwords["newPassword"] ?? "", completion: { isUpdated, error in
//                
//                if error == .invalidEmailOrPassword{
//                    self.alerts.errorAlert(self, errorTypeApi: .invalidEmailOrPassword)
//                    
//                } else if  error == .emailIsNotVerifyed{
//                    self.alerts.errorAlert(self, errorTypeApi: .unknown)
//                    
//                    
//                }else if error == .unknowmError{
//                    self.alerts.errorAlert(self, errorTypeApi: .unknown)
//                }
////                else if error == .notConnected{
////                    self.controllers.goToNoConnection(view: self.view, direction: .fade)
////                }
//                
//                if isUpdated{
//                    self.alerts.invalidToken(self, message: "Пароль успешно обновлен")                  
//                }
//                
//            })
//        }
        
    }
    
    // MARK: - Navigation
    
    fileprivate func goToBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension ChangePasswordViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        self.presenter.passwords[textField.restorationIdentifier!] = textField.text ?? ""
        
    }
}

extension ChangePasswordViewController:ChangePasswordViewProtocol{
    
}
