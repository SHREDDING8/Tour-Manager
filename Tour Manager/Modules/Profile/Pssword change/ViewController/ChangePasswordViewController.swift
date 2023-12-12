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

    func addDelegates(){
        self.view().oldPassword.textField.delegate = self
        self.view().newPassword.textField.delegate = self
        self.view().confirmPassword.textField.delegate = self
    }
    
    func addTargets(){
        self.view().changeButtonPassword.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
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
