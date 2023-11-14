//
//  ProfilePageViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 29.04.2023.
//

import UIKit

class ProfilePageViewController: UIViewController {
    
    // MARK: - my Variables
    
    var presenter:ProfilePagePresenter?
    
    var tableViewPosition:CGPoint!
    
    var caledarHeightConstaint:NSLayoutConstraint!
    
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
    
    
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    private let minTableViewTopConstraintConstant: CGFloat = 0
    private let maxTableViewTopConstraintConstant: CGFloat = 215
    private var previousContentOffsetY: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        presenter = ProfilePagePresenter(view: self)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = ProfilePagePresenter(view: self)
                        
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
        
        if (self.presenter?.isAccessLevel(key: .readGeneralCompanyInformation) ?? false){
            self.navigationItem.title = self.presenter?.getCompanyName() ?? ""
        }
        
        self.fullNameLabel.text = "\(self.presenter?.getFirstName() ?? "") \(self.presenter?.getSecondName() ?? "")"
        
        // image picker
        self.imagePicker.delegate = self
        let gestureChangePhoto = UITapGestureRecognizer(target: self, action: #selector(tapChangePhoto))
        
        self.profilePhoto.addGestureRecognizer(gestureChangePhoto)
        
//        self.changePhotoButton.addTarget(self, action: #selector(tapChangePhoto), for: .touchUpInside)
    }
    
    fileprivate func profilePhotoConfiguration(){
        self.profilePhoto.clipsToBounds = true
        self.profilePhoto.layer.masksToBounds = true
        
//        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
        
    }
    
    internal func setProfilePhoto(image:UIImage){
        UIView.transition(with: self.profilePhoto, duration: 0.3, options: .transitionCrossDissolve) {
        self.profilePhoto.image = image
    }
        
    }
    
    fileprivate func addSubviews(){
    }
    
    // MARK: - configure Date Picker
    fileprivate func datePickerConfiguration(){
        
//        self.datePicker = DatepickerFromBottom(viewController: self, doneAction: { date in
//            
//            self.presenter?.updatePersonalData(updateField: .birthdayDate, value: date.birthdayToString()) { isSetted, error in
//                if let err = error{
//                    self.alerts.errorAlert(self, errorUserDataApi: err) {
//                        self.dateLabel.text = self.presenter?.getBirthday()
//                    }
//                }
//                if isSetted{
//                    self.dateLabel.text = date.birthdayToString()
//                }
//            }
//        })
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
            
            self.presenter?.deleteProfilePhoto(completion: { isDeleted, error in
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
        return self.presenter?.isAccessLevel(key: .readGeneralCompanyInformation) ?? false ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor(named: "background")
        let title = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width - 30, height: 50))
        header.addSubview(title)
        
        title.textColor = UIColor(named: "blueText")
        
        title.font = UIFont(name: "American Typewriter Bold", size: 24)
        
        switch section{
        case 0: title.text = "Личные данные"
        case 1: self.presenter?.isAccessLevel(key: .readGeneralCompanyInformation) ?? false ? (title.text = "Компания") : (title.text = "")
        default: title.text = ""
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0: return self.presenter?.isAccessLevel(key: .isOwner) ?? false ? 6 : 7
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
            if self.presenter?.isAccessLevel(key: .readGeneralCompanyInformation) ?? false{
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContentOffsetY = scrollView.contentOffset.y
        let scrollDiff = currentContentOffsetY - self.previousContentOffsetY
        
        let bounceBorderContentOffsetY = -scrollView.contentInset.top
        
        
        let contentMovesUp = scrollDiff > 0 && currentContentOffsetY > bounceBorderContentOffsetY
           let contentMovesDown = scrollDiff < 0 && currentContentOffsetY < bounceBorderContentOffsetY
        
        
        var newConstraintConstant = self.tableViewTopConstraint.constant

        if contentMovesUp {
            // Уменьшаем константу констрэйнта
            newConstraintConstant = max(self.tableViewTopConstraint.constant - scrollDiff,minTableViewTopConstraintConstant)
        } else if contentMovesDown {
            // Увеличиваем константу констрэйнта
            newConstraintConstant = min(self.tableViewTopConstraint.constant - scrollDiff, maxTableViewTopConstraintConstant)
        }
        
        if newConstraintConstant != self.tableViewTopConstraint.constant {
            self.tableViewTopConstraint.constant = newConstraintConstant
            scrollView.contentOffset.y = previousContentOffsetY
            
        }
        
        self.previousContentOffsetY = scrollView.contentOffset.y
        
        let opacity = (self.tableViewTopConstraint.constant / self.maxTableViewTopConstraintConstant)
        self.profilePhoto.layer.opacity = Float(opacity)
        self.fullNameLabel.layer.opacity = Float(opacity)
//        self.changePhotoButton.layer.opacity = Float(opacity)
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
            changeButton.titleLabel?.font = Font.getFont(name: .americanTypewriter, style: .regular, size: 14)
        
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
                        
                        if self.presenter?.getFullName() == сonfirmAlert.textFields![0].text{
                            
                            self.presenter?.deleteCurrentUser(completion: { isDeleted, error in
                                
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
        
        let indexLocalId = self.presenter?.isAccessLevel(key: .readLocalIdCompany).toInt() ?? 0
        let indexCompanyEmploee = indexLocalId + (self.presenter?.isAccessLevel(key: .readCompanyEmployee).toInt() ?? 0)
        let indexDeleteCompany = indexCompanyEmploee + (self.presenter?.isAccessLevel(key: .isOwner).toInt() ?? 0)
        
        
        
        switch indexPath.row{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
            
            let textField:UITextField = cell.viewWithTag(2) as! UITextField
            textField.text = profileModel.getProfileCompanyDataFromUser(type: cellType)
            textField.restorationIdentifier = cellType.rawValue.2
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = cellType.rawValue.0
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            changeButton.titleLabel?.font = Font.getFont(name: .americanTypewriter, style: .regular, size: 14)
            
            changeButton.removeTarget(nil, action: nil, for: .touchUpInside)
            
            let action = UIAction(handler: { _ in
                textField.isEnabled = true
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                textField.becomeFirstResponder()
            })
            changeButton.addAction(action, for: .touchUpInside)
            
            if !(self.presenter?.isAccessLevel(key: .writeGeneralCompanyInformation) ?? false){
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
        changeButton.titleLabel?.font = Font.getFont(name: .americanTypewriter, style: .regular, size: 14)
        changeButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
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
        button.setTitle("Удалить аккаунт", for: .normal)
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        
        let actionExit = UIAction { _ in
            
            self.alerts.deleteAlert(self, title: "Вы действительно хотите удалить аккаунт?\nВы также удалите свою компанию", buttonTitle: "Удалить") {
                
                
                let confirmAlert = UIAlertController(title: "Введите название компании", message: nil, preferredStyle: .alert)
                confirmAlert.addTextField()
                
                
                let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    if self.presenter?.getCompanyName() ?? "x" == confirmAlert.textFields![0].text ?? "y"{
                        self.presenter?.DeleteCompany(completion: { isDeleted, error in
                            
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
                self.presenter?.logOut(completion: { isLogOut, error in
                    if error != nil{
                        
//                        if error == .notConnected{
//                            self.controllers.goToNoConnection(view: self.view, direction: .fade)
//                            return
//                        }
                        
                        let alert = self.alerts.infoAlert(title: "Неизвестная ошибка", meesage: "Вы не вышли из системы")
                        
                        self.present(alert, animated: true)
                    }
                })
                self.controllers.goToLoginPage(view: self.view, direction: .toBottom)
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
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.isEnabled = false
        let value = textField.text!
        
        
        if textField.restorationIdentifier == "firstName"{
            
            if validationString.validateIsEmptyString([value]){
                textField.text = self.presenter?.getFirstName()
                let alert = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
                self.present(alert, animated: true)
                return
            }
            
//            self.presenter?.updatePersonalData(updateField: .firstName, value: value) { isSetted, error in
//                
//                if let err = error{
//                    self.alerts.errorAlert(self, errorUserDataApi: err) {
//                        textField.text = self.presenter?.getFirstName()
//                    }
//                }
//                
//                if isSetted{
//                    self.fullNameLabel.text = self.presenter?.getFullName() ?? ""
//                }
//            }
            
        }else if textField.restorationIdentifier == "secondName"{
            
            if validationString.validateIsEmptyString([value]){
                textField.text = self.presenter?.getSecondName()
                let alert = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
                self.present(alert, animated: true)
                return
            }
            
//            self.presenter?.updatePersonalData(updateField: .secondName, value: value) { isSetted, error in
//                
//                if let err = error{
//                    self.alerts.errorAlert(self, errorUserDataApi: err) {
//                        textField.text = self.presenter?.getSecondName()
//                    }
//                }
//                
//                if isSetted{
//                    self.fullNameLabel.text = self.presenter?.getFullName() ?? ""
//                }
//            }
            
        } else if textField.restorationIdentifier == "phone"{
            
            let newPhone = textField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "") ?? ""
            
            textField.text = newPhone
            
            if !validationString.validatePhone(value: newPhone){
                let alert = alerts.errorAlert(errorTypeFront: .phone)
                self.present(alert, animated: true)
                return
            }
            
//            self.presenter?.updatePersonalData(updateField: .phone, value: newPhone) { isSetted, error in
//                
//                if let err = error{
//                    self.alerts.errorAlert(self, errorUserDataApi: err) {
//                        textField.text = self.presenter?.getPhone()
//                    }
//                }
//            }
            
        } else if textField.restorationIdentifier == "companyName"{
            if validationString.validateIsEmptyString([value]){
                textField.text = self.presenter?.getCompanyName()
                let alert = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
                self.present(alert, animated: true)
                return
            }
            
            self.presenter?.updateCompanyInfo(companyName: value, completion: { isUpdated, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorCompanyApi: err) {
                        textField.text = self.presenter?.getCompanyName()
                    }
                }
                                
                if isUpdated{
                    self.navigationItem.title = self.presenter?.getCompanyName()
                }
                
            })
            
        }
    }
}


// MARK: - UiImagePicker Delegate
extension ProfilePageViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            self.dismiss(animated: true)
            
            
            self.presenter?.uploadProfilePhoto(image: image, completion: { isUpload, error in
                
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

extension ProfilePageViewController:ProfileViewProtocol{
    
}
