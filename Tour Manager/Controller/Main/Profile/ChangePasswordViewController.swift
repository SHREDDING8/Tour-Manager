//
//  ChangePasswordViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.05.2023.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    // MARK: - My variables
    
    let user = AppDelegate.user
    let alerts = Alert()
    
    var passwords = [
        "oldPassword": "",
        "newPassword": "",
        "secondNewPassword": "",
    ]
    
    let stringValidation = StringValidation()
    
    var tableViewPosition:CGFloat!
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    

    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.frame.origin.y = tableViewPosition
    }

    

    

    
    // MARK: - Actions
    
    @IBAction func changePassword(_ sender: Any) {
        if stringValidation.validatePasswordsString(self.passwords["newPassword"] ?? "", self.passwords["secondNewPassword"] ?? ""){
            
            self.user?.updatePassword(oldPassword: self.passwords["oldPassword"] ?? "", newPassword: self.passwords["newPassword"] ?? "", completion: { isUpdated, error in
                
                if error == .invalidEmailOrPassword{
                    let error = self.alerts.errorAlert(errorTypeApi: .invalidEmailOrPassword)
                    self.present(error, animated: true)
                    
                } else if  error == .emailIsNotVerifyed{
                    let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(error, animated: true)
                    
                    
                }else if error == .unknowmError{
                    let error = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(error, animated: true)
                    
                }
                
                if isUpdated{
                    let alert = UIAlertController(title: "Пароль успешно обновлен", message: nil, preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "Ok", style: .default) { _ in
                        self.goToBack()
                    }
                    alert.addAction(actionOK)
                    self.present(alert, animated: true)
                    
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
        
        switch indexPath.row{
        case 0:
            label.text = "Старый пароль"
            textField.placeholder = "Старый пароль"
            textField.restorationIdentifier = "oldPassword"
        case 1:
            label.text = "Новый пароль"
            textField.placeholder = "Новый пароль"
            textField.restorationIdentifier = "newPassword"
        case 2:
            label.text = "Подтвердите пароль"
            textField.placeholder = "Подтвердите пароль"
            textField.restorationIdentifier = "secondNewPassword"

        default:
            break
        }
        
        return cell
    }
    
    
}

extension ChangePasswordViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        passwords[textField.restorationIdentifier!] = textField.text ?? ""
        
    }
}