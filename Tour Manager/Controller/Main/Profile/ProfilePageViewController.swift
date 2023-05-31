//
//  ProfilePageViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.04.2023.
//

import UIKit

let font = Font()

class ProfilePageViewController: UIViewController {
    
    // MARK: - my Variables
    
    var tableViewPosition:CGPoint!
    
    var caledarHeightConstaint:NSLayoutConstraint!
    
    let user = AppDelegate.user
    let controllers = Controllers()
    let profileModel = Profile()
    let alerts = Alert()
    let validationString = StringValidation()
    
    // MARK: - Outlets
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var datePickerUiView:UIView = {
        let buttonFont = font.getFont(name: .americanTypewriter, style: .bold, size: 16)
        let uiView = UIView()
        uiView.backgroundColor = .white
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        uiView.addSubview(picker)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = buttonFont
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        uiView.addSubview(doneButton)
        
        let cancelButton = UIButton(type: .system)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = buttonFont
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        uiView.addSubview(cancelButton)
        
        let line = UIView()
        line.backgroundColor = .gray
        line.translatesAutoresizingMaskIntoConstraints = false
        
        uiView.addSubview(line)
        
        return uiView
    }()
    
    var darkUiView:UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .black
        uiView.layer.opacity = 0
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user?.getAccessLevelFromApi(completion: { isGetted, error in
            if isGetted{
                self.configurationView()
                self.tableView.reloadData()
            }
        })
        
        
        configurationView()
        setKeyBoardObserver()
        
        addSubviews()
        
        profilePhotoConfiguration()
        configurationDarkUiView()
        datePickerConfiguration()
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewPosition = tableView.frame.origin
    
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyBoardObserver()
    }
    
    // MARK: - KeyBoard
    
    fileprivate func setKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    fileprivate func removeKeyBoardObserver(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if keyboardSize.origin.y - tableView.frame.origin.y  < 125{
                tableView.frame.origin = CGPoint(x: 0, y: self.profilePhoto.frame.origin.y - 10)
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.frame.origin.y = tableViewPosition.y
    }
    
    // MARK: - Configuration
    
    fileprivate func configurationView(){
        if self.user?.getAccessLevel(rule: .readGeneralCompanyInformation) == true{
            self.navigationItem.title = self.user?.company.getNameCompany()
        }
        self.fullNameLabel.text = self.user?.getFullName() ?? ""
    }
    
    fileprivate func profilePhotoConfiguration(){
        self.profilePhoto.clipsToBounds = true
        self.profilePhoto.layer.masksToBounds = true
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
    }
    
    fileprivate func addSubviews(){
        self.view.addSubview(self.darkUiView)
        self.view.addSubview(datePickerUiView)
    }
    
    // MARK: - configure Date Picker
    fileprivate func datePickerConfiguration(){
        
        let picker = datePickerUiView.subviews[0]
        
        let doneButton = datePickerUiView.subviews[1] as! UIButton
        
        let cancelButton = datePickerUiView.subviews[2]
        
        let line = datePickerUiView.subviews[3]
        
        
        let action = UIAction { _ in
            UIView.transition(with: self.datePickerUiView, duration: 0.5) {
                self.caledarHeightConstaint.constant = 0
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.tabBarController?.tabBar.layer.opacity = 1
                self.darkUiView.layer.opacity = 0
            }
        }
        doneButton.addAction(action, for: .touchUpInside)
        
        
        caledarHeightConstaint = NSLayoutConstraint(item: self.datePickerUiView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        self.datePickerUiView.addConstraint(caledarHeightConstaint)
        
        NSLayoutConstraint.activate([
            self.datePickerUiView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            self.datePickerUiView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.datePickerUiView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            picker.trailingAnchor.constraint(equalTo: self.datePickerUiView.trailingAnchor),
            picker.leadingAnchor.constraint(equalTo: self.datePickerUiView.leadingAnchor),
            picker.bottomAnchor.constraint(equalTo: self.datePickerUiView.bottomAnchor)
            ])
        
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: self.datePickerUiView.topAnchor, constant: 5),
            doneButton.trailingAnchor.constraint(equalTo: self.datePickerUiView.trailingAnchor, constant: -10),
            doneButton.bottomAnchor.constraint(equalTo: picker.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: self.datePickerUiView.topAnchor, constant: 5),
            cancelButton.leadingAnchor.constraint(equalTo: self.datePickerUiView.leadingAnchor, constant: 10),
            cancelButton.bottomAnchor.constraint(equalTo: picker.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            line.topAnchor.constraint(equalTo: doneButton.self.bottomAnchor, constant: 0),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    // MARK: - configure dark UiView
    
    fileprivate func configurationDarkUiView(){
        
        NSLayoutConstraint.activate([
            self.darkUiView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.darkUiView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.darkUiView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.darkUiView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    
    // MARK: - Button Taps
    
    
    
    // MARK: - Navigation
    fileprivate func goToLogInPage(){
        let mainLogIn = self.controllers.getControllerAuth(.mainAuthController)
        
        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toBottom
        options.duration = 0.3
        options.style = .easeOut
        
        window?.set(rootViewController: mainLogIn, options: options)
        
    }
    
    fileprivate func goToChangePasswordPage(){
        let changePasswordController = self.controllers.getControllerMain(.changePasswordViewController)
        
        self.navigationController?.pushViewController(changePasswordController, animated: true)
    }
    
    
}

// MARK: - UITableViewDelegate
extension ProfilePageViewController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.user?.getAccessLevel(rule: .readGeneralCompanyInformation) ?? false ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let title = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width - 30, height: 50))
        header.addSubview(title)
        
        header.backgroundColor = .white
        title.font = UIFont(name: "American Typewriter Bold", size: 24)
        
        switch section{
        case 0: title.text = "Личные данные"
        case 1: self.user?.getAccessLevel(rule: .readGeneralCompanyInformation) ?? false ? (title.text = "Компания") : (title.text = "")
        default: title.text = ""
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0: return self.user?.getAccessLevel(rule: .isOwner) ?? false ? 6 : 7
        case 1:
            return 1 + self.profileModel.getNumberCellCompanySection()
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section{
        case 0:
            cell = personalDataCell(indexPath: indexPath)
        case 1:
            if self.user?.getAccessLevel(rule: .readGeneralCompanyInformation) ?? false{
                cell = self.companyDataCell(indexPath: indexPath)
                
            }else{
                cell = self.exitFromAccountCell(indexPath: indexPath)
            }
        case 2:
            cell = self.exitFromAccountCell(indexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.restorationIdentifier == "changePasswordCell"{
            self.goToChangePasswordPage()
        }
    }
    
    // MARK: - PersonalData Cell
    
    fileprivate func personalDataCell(indexPath:IndexPath) -> UITableViewCell{
        var cell = UITableViewCell()
        let cellType = profileModel.getProfilePersonalDataCellType(index: indexPath.row)
        
        switch indexPath.row{
        case 0...1, 3...4:
            cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
            
            let textField:UITextField = cell.viewWithTag(2) as! UITextField
            textField.text = profileModel.getProfilePersonalDataFromUser(type: cellType)
            textField.restorationIdentifier = cellType.rawValue.2
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            
            let action = UIAction(handler: { _ in
                textField.isEnabled = true
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                textField.becomeFirstResponder()
            })
            changeButton.addAction(action, for: .touchUpInside)
        
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath)
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0
            
            let cellLabel2:UILabel = cell.viewWithTag(2) as! UILabel
            cellLabel2.text = profileModel.getProfilePersonalDataFromUser(type: cellType)
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            
            let action = UIAction(handler: { _ in
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
                UIView.transition(with: self.datePickerUiView, duration: 0.5) {
                    self.caledarHeightConstaint.constant = self.view.frame.height / 2
                    self.view.layoutIfNeeded()
                }
                UIView.animate(withDuration: 0.5, delay: 0) {
                    self.tabBarController?.tabBar.layer.opacity = 0
                    self.darkUiView.layer.opacity = 0.5
                }

            })
            changeButton.addAction(action, for: .touchUpInside)
        
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "otherPagesCell", for: indexPath)
                let cellLabel:UILabel = cell.viewWithTag(2) as! UILabel
                cellLabel.text = cellType.rawValue.0
            cell.restorationIdentifier = "changePasswordCell"
        
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
            let buttonDeleteAccount = cell.viewWithTag(1) as! UIButton
            buttonDeleteAccount.backgroundColor = .red
            buttonDeleteAccount.layer.cornerRadius = buttonDeleteAccount.frame.height / 2 - 1
            buttonDeleteAccount.setTitleColor(.white, for: .normal)
            buttonDeleteAccount.setTitle("Удалить аккаунт", for: .normal)
            
            let actionDel = UIAction { _ in
                
                let alert = UIAlertController(title: "Вы уверены в удалении аккаунта?", message: nil, preferredStyle: .alert)
                
                let actionDel = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    self.user?.deleteCurrentUser(completion: { isDeleted, error in
                        if error == .invalidToken || error == .tokenExpired{
                            let alert = self.alerts.invalidToken(view: self.view, message: "Мы не смогли удалить ваш аккаунт")
                            self.present(alert, animated: true)
                            
                        } else if error == .unknowmError{
                            let alert = self.alerts.errorAlert(errorTypeApi: .unknown)
                            self.present(alert, animated: true)
                        }
                        
                        if isDeleted{
                            let alert = self.alerts.infoAlert(title: "Ваш аккаунт был удален", meesage: nil)
                            self.present(alert, animated: true)
                        }
                        
                    })
                }
                
                let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                
                alert.addAction(cancel)
                alert.addAction(actionDel)
                self.present(alert, animated: true)
                
            }
            buttonDeleteAccount.addAction(actionDel, for: .touchUpInside)
        default:
            break
        }
        
        return cell
        
    }
    
    // MARK: - companyDataCell
    fileprivate func companyDataCell(indexPath:IndexPath) ->UITableViewCell{
        var cell = UITableViewCell()
        let cellType = profileModel.getProfileCompanyDataCellType(index: 1)
        
        let indexLocalId = self.user?.getAccessLevel(rule: .readLocalIdCompany).toInt() ?? 0
        let indexCompanyEmploee = indexLocalId + (self.user?.getAccessLevel(rule: .readCompanyEmployee).toInt() ?? 0)
        let indexDeleteCompany = indexCompanyEmploee + (self.user?.getAccessLevel(rule: .isOwner).toInt() ?? 0)
        
        
        
        switch indexPath.row{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
            
            let textField:UITextField = cell.viewWithTag(2) as! UITextField
            textField.text = profileModel.getProfileCompanyDataFromUser(type: cellType)
            textField.restorationIdentifier = cellType.rawValue.2
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            
            let action = UIAction(handler: { _ in
                textField.isEnabled = true
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                textField.becomeFirstResponder()
            })
            changeButton.addAction(action, for: .touchUpInside)
            
            if !(self.user?.getAccessLevel(rule: .writeGeneralCompanyInformation) ?? false){
                changeButton.isHidden = true
            }
            
        case 1:
            if indexLocalId == 1{
                cell = CompanyIdCell(indexPath: indexPath)
            } else if indexCompanyEmploee == 1{
                cell = emploeeCell(indexPath: indexPath)
            } else if indexDeleteCompany == 1{
                cell = deleteCompanyCell(indexPath: indexPath)
            }
        case 2:
            if indexCompanyEmploee == 2{
                cell = emploeeCell(indexPath: indexPath)
            } else if indexDeleteCompany == 2{
                cell = deleteCompanyCell(indexPath: indexPath)
            }
        case 3:
            if indexDeleteCompany == 3{
                cell = deleteCompanyCell(indexPath: indexPath)
            }
        default:
            break
        }
        
        
        return cell
    }
    
    fileprivate func CompanyIdCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
        let cellType = profileModel.getProfileCompanyDataCellType(index: 0)
        
        let textField:UITextField = cell.viewWithTag(2) as! UITextField
        textField.text = profileModel.getProfileCompanyDataFromUser(type: cellType)
        textField.restorationIdentifier = cellType.rawValue.2
        
        let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
        cellLabel.text = cellType.rawValue.0
        
        let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
        changeButton.setTitle("Скопировать", for: .normal)
        
        let action = UIAction(handler: { _ in
            UIPasteboard.general.string = textField.text ?? ""
            
            let alert = UIAlertController(title: "Id компании был скопирован", message: nil, preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(actionOk)
            self.present(alert, animated: true)
        })
        changeButton.addAction(action, for: .touchUpInside)
        
        return cell
    }
    
    public func emploeeCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherPagesCell", for: indexPath)
        cell.restorationIdentifier = "emploeeCell"
        
        let cellType = profileModel.getProfileCompanyDataCellType(index: 2)
        
        let cellLabel:UILabel = cell.viewWithTag(2) as! UILabel
        cellLabel.text = cellType.rawValue.0
        
        return cell
    }
    
    public func deleteCompanyCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
        
        let button = cell.viewWithTag(1) as! UIButton
        button.backgroundColor = .red
        button.layer.cornerRadius = button.frame.height / 2 - 1
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Удалить компанию", for: .normal)
        
        let actionExit = UIAction { _ in
            
        }
        button.addAction(actionExit, for: .touchUpInside)
        
        return cell
    }
    
    public func exitFromAccountCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
        
        let button = cell.viewWithTag(1) as! UIButton
        let actionExit = UIAction { _ in
            self.goToLogInPage()
        }
        
        button.addAction(actionExit, for: .touchUpInside)
        return cell
        
    }
    
    
}

// MARK: - Text Field Delegate

extension ProfilePageViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isEnabled = false
        let value = textField.text!
        
        
        if textField.restorationIdentifier == "firstName"{
            
            if validationString.validateIsEmptyString([value]){
                textField.text = self.user?.getFirstName()
                let alert = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
                self.present(alert, animated: true)
                return false
            }
            
            self.user?.updatePersonalData(updateField: .firstName, value: value) { isSetted, error in
                
                if error == .tokenExpired || error == .invalidToken{
                    textField.text = self.user?.getFirstName()
                    let alert  = self.alerts.invalidToken(view: self.view, message: "")
                    self.present(alert, animated: true)
                } else if error == .unknowmError{
                    textField.text = self.user?.getFirstName()
                    let alert  = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(alert, animated: true)
                }
                
                if isSetted{
                    self.fullNameLabel.text = self.user?.getFullName() ?? ""
                }
            }
            
        }else if textField.restorationIdentifier == "secondName"{
            
            if validationString.validateIsEmptyString([value]){
                textField.text = self.user?.getSecondName()
                let alert = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
                self.present(alert, animated: true)
                return false
            }
            
            self.user?.updatePersonalData(updateField: .secondName, value: value) { isSetted, error in
                
                if error == .tokenExpired || error == .invalidToken{
                    textField.text = self.user?.getSecondName()
                    let alert  = self.alerts.invalidToken(view: self.view, message: "")
                    self.present(alert, animated: true)
                } else if error == .unknowmError{
                    textField.text = self.user?.getSecondName()
                    let alert  = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(alert, animated: true)
                }
                
                if isSetted{
                    self.fullNameLabel.text = self.user?.getFullName() ?? ""
                }
            }
            
        } else if textField.restorationIdentifier == "phone"{
            
            if !validationString.validatePhone(value: value){
                let alert = alerts.errorAlert(errorTypeFront: .phone)
                self.present(alert, animated: true)
                return false
            }
            
            self.user?.updatePersonalData(updateField: .phone, value: value) { isSetted, error in
                if error == .tokenExpired || error == .invalidToken{
                    textField.text = self.user?.getPhone()
                    let alert  = self.alerts.invalidToken(view: self.view, message: "")
                    self.present(alert, animated: true)
                } else if error == .unknowmError{
                    textField.text = self.user?.getPhone()
                    let alert  = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(alert, animated: true)
                }
            }
            
        } else if textField.restorationIdentifier == "companyName"{
            if validationString.validateIsEmptyString([value]){
                textField.text = self.user?.company.getNameCompany()
                let alert = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
                self.present(alert, animated: true)
                return false
            }
            
            self.user?.company.updateCompanyInfo(token: self.user?.getToken() ?? "", companyName: value, completion: { isUpdated, error in
                
                if error == .tokenExpired || error == .invalidToken{
                    textField.text = self.user?.company.getNameCompany()
                    let alert  = self.alerts.invalidToken(view: self.view, message: "")
                    self.present(alert, animated: true)
                } else if error != nil{
                    textField.text = self.user?.company.getNameCompany()
                    let alert  = self.alerts.errorAlert(errorTypeApi: .unknown)
                    self.present(alert, animated: true)
                }
                
                if isUpdated{
                    self.navigationItem.title = self.user?.company.getNameCompany()
                }
                
            })
            
        }
        return true
    }
}
