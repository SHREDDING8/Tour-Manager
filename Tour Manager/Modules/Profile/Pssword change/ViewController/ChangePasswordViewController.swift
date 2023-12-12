//
//  ChangePasswordViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit
import AlertKit

class ChangePasswordViewController: BaseViewController{
    
    // MARK: - My variables
    var presenter:ChangePasswordPresenterProtocol!
    
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
        addTargets()
        
        self.titleString = "Смена пароля"
        self.setBackButton()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObservers()
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
    
    func addTargets(){
        self.view().changeButtonPassword.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
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
    
    @objc private func changePassword() {
        self.presenter.updatePassword()
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
    func passwordsAreNotTheSame() {
        let alert = UIAlertController(title: "Пароли не совпадают", message: nil, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func weakPassword(){
        let alert = UIAlertController(title: "Слабый пароль", message: nil, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func passwordUpdated() {
        AlertKitAPI.present(
            title: "Пароль обновлен",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    
}
