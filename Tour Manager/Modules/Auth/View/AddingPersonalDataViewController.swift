//
//  AddingPersonalDataViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit


class AddingPersonalDataViewController: UIViewController {
    
    var presenter: AddingPersonalDataPresenterProtocol?
    
    
    // MARK: - Me variables
    
    let validationStrings = StringValidation()
    let alerts = Alert()
    
    let controllers = Controllers()
    
    var loadUIView:LoadView!
    
    var datePicker:DatepickerFromBottom!
    
    
    var caledarHeightConstaint:NSLayoutConstraint!
    var tableViewPosition:CGPoint!
    
    var dateLabel:UILabel!
    
    var nameCompanyLocalIdString = ""
    var firstNameString = ""
    var secondNameString = ""
    var phoneString = ""
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var iconAppImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
        
    var localIdNameCompany:UITextField!
    
    var firstName:UITextField!
    var secondName:UITextField!
    
    var birthdayDate:Date = Date()
    var phone:UITextField!
    
    
    
    
    
    var typeOfRegister:TypeOfRegister = .company
    
    // MARK: - Life Cycle
    
    override func loadView() {
        super.loadView()
        self.presenter = AddingPersonalDataPresenter(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUIView = LoadView(viewController: self)
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        
        
        addSubviews()
        
        datePickerConfiguration()
        
        keyboardSetObservers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewPosition = tableView.frame.origin
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.keyboardRemoveObservers()
    }
    
    fileprivate func addSubviews(){
    }
    
    
    // MARK: - configure Date Picker
    fileprivate func datePickerConfiguration(){
        self.datePicker = DatepickerFromBottom(viewController: self, doneAction: { date in
            self.dateLabel.text = self.setDateLabel(date: date)
            self.birthdayDate = date
        })
    }
        
    fileprivate func setDateLabel(date:Date) -> String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yy"
        let dateString = dateformatter.string(from: date)
        return dateString
    }
    
    
    
    // MARK: - KeyBoard
    
    fileprivate func keyboardSetObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func keyboardRemoveObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if keyboardSize.origin.y - tableView.frame.origin.y  < 125{
                tableView.frame.origin = CGPoint(x: 0, y: self.iconAppImage.frame.origin.y - 5)
                
                UIView.animate(withDuration: 0.3) {
                    self.iconAppImage.layer.opacity = 0
                }

            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.frame.origin.y = tableViewPosition.y
        UIView.animate(withDuration: 0.3) {
            self.iconAppImage.layer.opacity = 1
        }
    }
    
    
    
    // MARK: - SetPersonalData in to Server
    
    @IBAction func setPersonalDataTapped(_ sender: Any) {
        
        self.loadUIView.setLoadUIView()
        
        if validationStrings.validateIsEmptyString([self.nameCompanyLocalIdString,self.firstNameString,self.secondNameString,self.phoneString]){
            let error = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
            self.present(error, animated: true)
            self.loadUIView.removeLoadUIView()
            return
        }
        
        if !validationStrings.validatePhone(value: self.phoneString){
            let error = alerts.errorAlert(errorTypeFront: .phone)
            self.present(error, animated: true)
            self.loadUIView.removeLoadUIView()
            return
        }
        
        self.presenter?.firstName = firstName.text ?? ""
        self.presenter?.secondName = secondName.text ?? ""
        self.presenter?.phone = phone.text ?? ""
        self.presenter?.birthday = self.birthdayDate.birthdayToString()
                
        switch typeOfRegister {
        case .emploee:
            self.presenter?.companyLocalId = localIdNameCompany.text ?? ""
        case .company:
            self.presenter?.companyName = localIdNameCompany.text ?? ""
        }
        
        
        self.presenter?.setUserInfoApi(completion: { IsSetted, error in
            if let err = error{
                self.alerts.errorAlert(self, errorUserDataApi: err) {
                    self.loadUIView.removeLoadUIView()
                }
                return
            }
            
            if IsSetted {
                switch self.typeOfRegister {
                case .emploee:
                    self.presenter?.addEmployeeToCompany(completion: { isAdded, error in
                        self.loadUIView.removeLoadUIView()
                        if let err = error{
                            self.alerts.errorAlert(self, errorCompanyApi: err) {
                                self.controllers.goToLoginPage(view: self.view, direction: .fade)
                            }
                        }
                        if isAdded{
                            self.controllers.goToMainTabBar(view: self.view, direction: .fade)
                        }
                        
                    })
                    
                case .company:
                    self.presenter?.setCompanyNameApi( completion: { isAdded, error in
                        self.loadUIView.removeLoadUIView()
                        if let err = error {
                            self.alerts.errorAlert(self, errorCompanyApi: err) {
                                self.controllers.goToLoginPage(view: self.view, direction: .fade)
                            }
                        }
                        if isAdded{
                            self.controllers.goToMainTabBar(view: self.view, direction: .fade)
                        }
                    })
                }
            }
        })
        
    }
    
    // MARK: - Navigation
        
    @objc fileprivate func goToLogInPage(){
        let mainLogIn = self.controllers.getControllerAuth(.mainAuthController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toBottom
        options.duration = 0.3
        options.style = .easeIn
        
        window?.set(rootViewController: mainLogIn,options: options)
        
    }


    
}

// MARK: - UITableViewDelegate
extension AddingPersonalDataViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        switch self.typeOfRegister{
        case .company:
            cell = self.cellsNewCompany(tableView: tableView, indexPath: indexPath)
        case .emploee:
            cell = self.cellsNewEmployee(tableView: tableView, indexPath: indexPath)
        }
        
        return cell
    }
    
    
    // MARK: - cellsNewCompany
    fileprivate func cellsNewCompany(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
        
        let textField = cell.viewWithTag(2) as! UITextField
        textField.text = ""
        let label = cell.viewWithTag(1) as! UILabel
        
        
        switch indexPath.row{
        case 0:
            
            cell.restorationIdentifier = "localIdNameCompany"
            
            label.text = "Название компании"
            textField.placeholder = "Название компании"
            textField.restorationIdentifier = "localIdNameCompany"
            
            textField.text = self.nameCompanyLocalIdString
            
            self.localIdNameCompany = textField
        case 1:
            label.text = "Имя"
            textField.placeholder = "Имя"
            self.firstName = textField
            
            textField.restorationIdentifier = "firstName"
            cell.restorationIdentifier = "firstName"
            
            textField.text = self.firstNameString
        case 2:
            label.text = "Фамилия"
            textField.placeholder = "Фамилия"
            self.secondName = textField
            
            textField.restorationIdentifier = "secondName"
            cell.restorationIdentifier = "secondName"
            
            
            textField.text = self.secondNameString
            
        case 4:
            label.text = "Телефон"
            textField.placeholder = "Телефон"
            
            self.phone = textField
            
            textField.restorationIdentifier = "phone"
            cell.restorationIdentifier = "phone"
            
            textField.keyboardType = .phonePad
            textField.addDoneCancelToolbar()
            
            textField.text = self.phoneString
            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath)
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = "Дата рождения"
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            
            self.dateLabel = (cell.viewWithTag(2) as! UILabel)
            self.dateLabel.text = setDateLabel(date: Date.now)
            self.birthdayDate = Date.now
            
            let action = UIAction(handler: { _ in
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
                self.firstName.resignFirstResponder()
                self.secondName.resignFirstResponder()
                self.phone.resignFirstResponder()
                self.localIdNameCompany.resignFirstResponder()
                
                self.datePicker.setDatePicker()

            })
            changeButton.addAction(action, for: .touchUpInside)
            
        default:
            break
        }
        
        
        return cell
    }
    
    fileprivate func cellsNewEmployee(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
        
        let textField = cell.viewWithTag(2) as! UITextField
        textField.text = ""
        
        textField.isUserInteractionEnabled = true
        
        let label = cell.viewWithTag(1) as! UILabel
        
        switch indexPath.row{
        case 0:
            label.text = "Id компании"
            textField.placeholder = "Id компании"
            textField.restorationIdentifier = "localIdNameCompany"
            
            textField.text = self.nameCompanyLocalIdString
            
            self.localIdNameCompany = textField
        case 1:
            label.text = "Имя"
            textField.placeholder = "Имя"
            self.firstName = textField
            
            textField.restorationIdentifier = "firstName"
            
            textField.text = self.firstNameString
        case 2:
            label.text = "Фамилия"
            textField.placeholder = "Фамилия"
            self.secondName = textField
            
            textField.restorationIdentifier = "secondName"
            
            textField.text = self.secondNameString
            
        case 4:
            label.text = "Телефон"
            textField.placeholder = "Телефон"
            self.phone = textField
            
            textField.keyboardType = .phonePad
            textField.addDoneCancelToolbar()
            
            textField.restorationIdentifier = "phone"
            
            textField.text = self.phoneString
            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath)
            
            let cellLabel:UILabel = cell.viewWithTag(1) as! UILabel
            cellLabel.text = "Дата рождения"
            
            let changeButton:UIButton = cell.viewWithTag(3) as! UIButton
            
            self.dateLabel = (cell.viewWithTag(2) as! UILabel)
            self.dateLabel.text = setDateLabel(date: Date.now)
            self.birthdayDate = Date.now
            
            let action = UIAction(handler: { _ in
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
                self.firstName.resignFirstResponder()
                self.secondName.resignFirstResponder()
                self.phone.resignFirstResponder()
                self.localIdNameCompany.resignFirstResponder()
                
                self.datePicker.setDatePicker()
                
            })
            changeButton.addAction(action, for: .touchUpInside)
        default:
            break
        }
        
        return cell
    }
    
}



// MARK: - UITextFieldDelegate

extension AddingPersonalDataViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.restorationIdentifier == "localIdNameCompany"{

            self.firstName.becomeFirstResponder()
            
        }else if textField.restorationIdentifier == "firstName"{
            self.secondName.becomeFirstResponder()
            
        }else if textField.restorationIdentifier == "secondName"{
            self.phone.becomeFirstResponder()
            
        }else if textField.restorationIdentifier == "phone"{
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if textField.restorationIdentifier == "localIdNameCompany"{
            self.nameCompanyLocalIdString = textField.text ?? ""
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
        }else if textField.restorationIdentifier == "firstName"{
            self.firstNameString = textField.text ?? ""
            tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
            
        }else if textField.restorationIdentifier == "secondName"{
            self.secondNameString = textField.text ?? ""
            tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
            
        }else if textField.restorationIdentifier == "phone"{
            
            let newPhone = textField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "") ?? ""
            
            self.phoneString = newPhone
            textField.text = newPhone
            
            tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true)
        }
    }
}

extension AddingPersonalDataViewController:AddingPersonalDataViewProtocol{
    
}
