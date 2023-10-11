//
//  ChangePasswordViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

class ChangePasswordViewController: UIViewController, ChangePasswordViewProtocol {
    
    // MARK: - My variables
    var presenter:ChangePasswordPresenterProtocol!
    
    let alerts = Alert()
    
    let controllers = Controllers()
    
    var passwords = [
        "oldPassword": "",
        "newPassword": "",
        "secondNewPassword": "",
    ]
    
    let stringValidation = StringValidation()
    
    var oldPassword:UITextField!
    var firstPassword:UITextField!
    var secondPassword:UITextField!
    
    var tableViewPosition:CGFloat!
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    

    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ChangePasswordPresenter(view: self)
        
        self.addKeyboardObservers()
        self.configureView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewPosition = tableView.frame.origin.y
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.origin.y - tableView.frame.origin.y  < 140{
                tableView.frame.origin.y = self.iconImageView.frame.origin.y - 10
                
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.iconImageView.layer.opacity = 0
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let position = tableViewPosition{
            tableView.frame.origin.y = position
        }
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.iconImageView.layer.opacity = 1
        }
    }

    

    

    
    // MARK: - Actions
    
    @IBAction func changePassword(_ sender: Any) {
        if stringValidation.validatePasswordsString(self.passwords["newPassword"] ?? "", self.passwords["secondNewPassword"] ?? ""){
            
            self.presenter.updatePassword(oldPassword: self.passwords["oldPassword"] ?? "", newPassword: self.passwords["newPassword"] ?? "", completion: { isUpdated, error in
                
                if error == .invalidEmailOrPassword{
                    self.alerts.errorAlert(self, errorTypeApi: .invalidEmailOrPassword)
                    
                } else if  error == .emailIsNotVerifyed{
                    self.alerts.errorAlert(self, errorTypeApi: .unknown)
                    
                    
                }else if error == .unknowmError{
                    self.alerts.errorAlert(self, errorTypeApi: .unknown)
                }
//                else if error == .notConnected{
//                    self.controllers.goToNoConnection(view: self.view, direction: .fade)
//                }
                
                if isUpdated{
                    self.alerts.invalidToken(self, message: "Пароль успешно обновлен")                  
                }
                
            })
        }
        
    }
    
    // MARK: - Navigation
    
    fileprivate func goToBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension ChangePasswordViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passwordCell")!
        let label = cell.viewWithTag(1) as! UILabel
        
        let textField = cell.viewWithTag(2) as! UITextField
        
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        
        switch indexPath.row{
        case 0:
            label.text = "Старый пароль"
            textField.placeholder = "Старый пароль"
            textField.restorationIdentifier = "oldPassword"
            self.oldPassword = textField
            
        case 1:
            label.text = "Новый пароль"
            textField.placeholder = "Новый пароль"
            textField.restorationIdentifier = "newPassword"
            self.firstPassword = textField
            
        case 2:
            label.text = "Подтвердите пароль"
            textField.placeholder = "Подтвердите пароль"
            textField.restorationIdentifier = "secondNewPassword"
            self.secondPassword = textField

        default:
            break
        }
        
        return cell
    }
    
    
}

extension ChangePasswordViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.oldPassword{
            self.firstPassword.becomeFirstResponder()
        } else if textField == self.firstPassword{
            self.secondPassword.becomeFirstResponder()
        } else{
            textField.resignFirstResponder()
        }
        
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        passwords[textField.restorationIdentifier!] = textField.text ?? ""
        
    }
}
