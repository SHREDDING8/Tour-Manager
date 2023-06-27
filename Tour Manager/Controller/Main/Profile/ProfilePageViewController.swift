//
//  ProfilePageViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.04.2023.
//

import UIKit

class ProfilePageViewController: UIViewController {
    
    // MARK: - my Variables
    
    var tableViewPosition:CGPoint!
    
    var caledarHeightConstaint:NSLayoutConstraint!
    
    let user = AppDelegate.user
    let controllers = Controllers()
    let profileModel = Profile()
    let alerts = Alert()
    let validationString = StringValidation()
    
    var datePicker:DatepickerFromBottom!
    
    var dateLabel:UILabel!
    
    
    let imagePicker:UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        return picker
    }()
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var changePhotoButton: UIButton!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        configurationView()
        setKeyBoardObserver()
        
        addSubviews()
        
        profilePhotoConfiguration()
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
        
        // image picker
        self.imagePicker.delegate = self
        let gestureChangePhoto = UITapGestureRecognizer(target: self, action: #selector(tapChangePhoto))
        
        self.profilePhoto.addGestureRecognizer(gestureChangePhoto)
        
        self.changePhotoButton.addTarget(self, action: #selector(tapChangePhoto), for: .touchUpInside)
    }
    
    fileprivate func profilePhotoConfiguration(){
        self.profilePhoto.clipsToBounds = true
        self.profilePhoto.layer.masksToBounds = true
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
        
        self.user?.downloadProfilePhoto(localId: self.user?.getLocalID() ?? "", completion: { data, error in
            if data != nil{
                self.setProfilePhoto(image: UIImage(data: data!)!)
            }
        })
    }
    
    fileprivate func setProfilePhoto(image:UIImage){
        UIView.transition(with: self.profilePhoto, duration: 0.3, options: .transitionCrossDissolve) {
        self.profilePhoto.image = image
    }
        
    }
    
    fileprivate func addSubviews(){
    }
    
    // MARK: - configure Date Picker
    fileprivate func datePickerConfiguration(){
        
        self.datePicker = DatepickerFromBottom(viewController: self, doneAction: { date in
            self.user?.updatePersonalData(updateField: .birthdayDate, value: date.birthdayToString()) { isSetted, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err) {
                        self.dateLabel.text = self.user?.getBirthday()
                    }
                }
                if isSetted{
                    self.dateLabel.text = date.birthdayToString()
                }
            }
        })
    }
    // MARK: - Image
    
    @objc fileprivate func tapChangePhoto(){
        let alert = UIAlertController(title: "Change photo", message: "Select how you want to upload photo", preferredStyle: .actionSheet)
        
        let actionLibary = UIAlertAction(title: "Library", style: .default) { [self] _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { [self] _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        
        let actionDeletePhoto = UIAlertAction(title: "Delete Photo", style: .default) { [self] _ in
            
            self.user?.deleteProfilePhoto(completion: { isDeleted, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err)
                }
                
                if isDeleted{
                    self.setProfilePhoto(image: UIImage(named: "no profile photo")!)
                }
            })
            
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(actionLibary)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        if profilePhoto.image != UIImage(named: "no profile photo")!{
            alert.addAction(actionDeletePhoto)
        }
        
        
        self.present(alert, animated: true)
     }
    
    
    
    
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
    fileprivate func goToEmploeePage(){
        let destination = self.controllers.getControllerMain(.emploeeTableViewController)
        
        self.navigationController?.pushViewController(destination, animated: true)
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
        } else if cell?.restorationIdentifier == "emploeeCell"{
            self.goToEmploeePage()
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
            changeButton.titleLabel?.font = Font.getFont(name: .americanTypewriter, style: .light, size: 14)
            changeButton.setTitle("Изменить", for: .normal)
        
            changeButton.removeTarget(nil, action: nil, for: .touchUpInside)
           
            
            let action = UIAction(handler: { _ in
                textField.isEnabled = true
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                textField.becomeFirstResponder()
            })
            changeButton.addAction(action, for: .touchUpInside)
            
            if cellType == .email{
                changeButton.isHidden = true
            }else{
                changeButton.isHidden = false
            }
            
            if cellType == .phone{
                textField.keyboardType = .phonePad
                textField.addDoneCancelToolbar()
            }
        
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath)
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0
            
            let cellLabel2:UILabel = cell.viewWithTag(2) as! UILabel
            cellLabel2.text = profileModel.getProfilePersonalDataFromUser(type: cellType)
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            changeButton.removeTarget(nil, action: nil, for: .touchUpInside)
            
            self.dateLabel = cellLabel2
            
            let action = UIAction(handler: { _ in
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
                self.view.endEditing(true)
                
                self.datePicker.setDatePicker()

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
            buttonDeleteAccount.removeTarget(nil, action: nil, for: .touchUpInside)
            
            let actionDel = UIAction { _ in
                
                self.alerts.deleteAlert(self, title: "Вы уверены что хотите удалить аккаунт?", buttonTitle: "Удалить") {
                    let сonfirmAlert = UIAlertController(title: "Введите свое имя и фамилию", message: nil, preferredStyle: .alert)
                    
                    сonfirmAlert.addTextField()
                    
                    
                    
                    let actionDel = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                        
                        if self.user?.getFullName() == сonfirmAlert.textFields![0].text{
                            self.user?.deleteCurrentUser(completion: { isDeleted, error in
                                
                                if let err = error{
                                    self.alerts.errorAlert(self, errorUserDataApi: err)
                                }
                                
                                if isDeleted{
                                    self.alerts.invalidToken(self, message: "Ваш аккаунт был удален")
                                }
                                
                            })
                        }else{
                            let infoAlert = self.alerts.infoAlert(title: "Неправильно введены данные", meesage: nil)
                            self.present(infoAlert, animated: true)
                        }
                        
                    }
                    
                    let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                    
                    сonfirmAlert.addAction(cancel)
                    сonfirmAlert.addAction(actionDel)
                    self.present(сonfirmAlert, animated: true)
                    
                }
                
            }
            buttonDeleteAccount.addAction(actionDel, for: .touchUpInside)
        default:
            break
        }
        
        return cell
        
    }
    
    @objc public func changeTextFieldValue(textField:UITextField, indexPath:IndexPath){
        textField.isEnabled = true
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        textField.becomeFirstResponder()
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
            changeButton.titleLabel?.font = Font.getFont(name: .americanTypewriter, style: .light, size: 14)
            changeButton.setTitle("Изменить", for: .normal)
            
            changeButton.removeTarget(nil, action: nil, for: .touchUpInside)
            
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
        changeButton.titleLabel?.font = Font.getFont(name: .americanTypewriter, style: .light, size: 14)
        changeButton.setTitle("Скопировать", for: .normal)
        changeButton.removeTarget(nil, action: nil, for: .touchUpInside)
        
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
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        
        let actionExit = UIAction { _ in
            
            self.alerts.deleteAlert(self, title: "Вы действительно хотите удалить компанию?", buttonTitle: "Удалить") {
                
                
                let confirmAlert = UIAlertController(title: "Введите название компании", message: nil, preferredStyle: .alert)
                confirmAlert.addTextField()
                
                
                let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    if self.user?.company.getNameCompany() ?? "x" == confirmAlert.textFields![0].text ?? "y"{
                        self.user?.company.DeleteCompany(token: self.user?.getToken() ?? "", completion: { isDeleted, error in
                            
                            if let err = error{
                                self.alerts.errorAlert(self, errorCompanyApi: err)
                            }
                            if isDeleted{
                                self.alerts.invalidToken(self, message: "Ваша компания была удалена")
                            }
                        })
                    }else{
                        let alert = self.alerts.infoAlert(title: "Неправильное название компании", meesage: nil)
                        self.present(alert, animated: true)
                    }
                }
                
                let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                
                confirmAlert.addAction(deleteButton)
                confirmAlert.addAction(cancel)
                
                self.present(confirmAlert, animated: true)
                
                
            }
            
            
            
            
            
            
            
        }
        button.addAction(actionExit, for: .touchUpInside)
        
        return cell
    }
    
    public func exitFromAccountCell(indexPath:IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
        
        let button = cell.viewWithTag(1) as! UIButton
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        let actionExit = UIAction { _ in
            
            self.alerts.deleteAlert(self, title: "Вы уверены что хотите выйти?", buttonTitle: "Выйти") {
                self.goToLogInPage()
            }
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
                
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err) {
                        textField.text = self.user?.getFirstName()
                    }
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
                
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err) {
                        textField.text = self.user?.getSecondName()
                    }
                }
                
                if isSetted{
                    self.fullNameLabel.text = self.user?.getFullName() ?? ""
                }
            }
            
        } else if textField.restorationIdentifier == "phone"{
            
            let newPhone = textField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "") ?? ""
            
            textField.text = newPhone
            
            if !validationString.validatePhone(value: newPhone){
                let alert = alerts.errorAlert(errorTypeFront: .phone)
                self.present(alert, animated: true)
                return false
            }
            
            self.user?.updatePersonalData(updateField: .phone, value: newPhone) { isSetted, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err) {
                        textField.text = self.user?.getPhone()
                    }
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
                
                if let err = error{
                    self.alerts.errorAlert(self, errorCompanyApi: err) {
                        textField.text = self.user?.company.getNameCompany()
                    }
                }
                                
                if isUpdated{
                    self.navigationItem.title = self.user?.company.getNameCompany()
                }
                
            })
            
        }
        return true
    }
}


// MARK: - UiImagePicker Delegate
extension ProfilePageViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            self.dismiss(animated: true)
            
            
            self.user?.uploadProfilePhoto(image: image, completion: { isUpload, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorUserDataApi: err)
                }
                
                if isUpload{
                    self.setProfilePhoto(image: image)
                }
            })
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
