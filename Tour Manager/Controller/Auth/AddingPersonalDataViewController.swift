//
//  AddingPersonalDataViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit


class AddingPersonalDataViewController: UIViewController {
    
    
    // MARK: - Me variables
    
    let validationStrings = StringValidation()
    let alerts = Alert()
    
    let controllers = Controllers()
    
    let user = AppDelegate.user
    
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
    
    
    var localIdNameCompany:UITextField!
    
    var firstName:UITextField!
    var secondName:UITextField!
    
    var birthdayDate:Date = Date()
    var phone:UITextField!
    
    
    
    
    
    var typeOfRegister:TypeOfRegister = .company
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        
        
        addSubviews()
        
        datePickerConfiguration()
        configurationDarkUiView()
        
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
        self.view.addSubview(self.darkUiView)
        self.view.addSubview(datePickerUiView)
    }
    
    
    // MARK: - configure Date Picker
    fileprivate func datePickerConfiguration(){
        
        let picker = datePickerUiView.subviews[0] as! UIDatePicker
        
        let doneButton = datePickerUiView.subviews[1] as! UIButton
        
        let cancelButton = datePickerUiView.subviews[2] as! UIButton
        
        let line = datePickerUiView.subviews[3]
        
        
        let doneAction = UIAction { _ in
            UIView.transition(with: self.datePickerUiView, duration: 0.5) {
                self.caledarHeightConstaint.constant = 0
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.tabBarController?.tabBar.layer.opacity = 1
                self.darkUiView.layer.opacity = 0
            }
            
            self.dateLabel.text = self.setDateLabel(date: picker.date)
            self.birthdayDate = picker.date
        }
        
        let cancelAction = UIAction { _ in
            UIView.transition(with: self.datePickerUiView, duration: 0.5) {
                self.caledarHeightConstaint.constant = 0
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.tabBarController?.tabBar.layer.opacity = 1
                self.darkUiView.layer.opacity = 0
            }
            
        }
        
        doneButton.addAction(doneAction, for: .touchUpInside)
        cancelButton.addAction(cancelAction, for: .touchUpInside)
        
        
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
        

        if validationStrings.validateIsEmptyString([self.nameCompanyLocalIdString,self.firstNameString,self.secondNameString,self.phoneString]){
            let error = alerts.errorAlert(errorTypeFront: .textFieldIsEmpty)
            self.present(error, animated: true)
            return
        }
        
        if !validationStrings.validatePhone(value: self.phoneString){
            let error = alerts.errorAlert(errorTypeFront: .phone)
            self.present(error, animated: true)
            return
        }
        self.user?.setFirstName(firstName: firstName.text!)
        self.user?.setSecondName(secondName: secondName.text!)
        self.user?.setPhone(phone: phone.text!)
        self.user?.setBirthday(birthday: self.birthdayDate)
        
        switch typeOfRegister {
        case .emploee:
            self.user?.company.setLocalIDCompany(localIdCompany: localIdNameCompany.text!)
        case .company:
            self.user?.company.setNameCompany(nameCompany: localIdNameCompany.text!)
        }
        
        
        
        self.user?.setUserInfoApi(completion: { IsSetted, error in
            if error != nil {
                let alert = self.alerts.errorAlert(errorTypeApi: .unknown)
                self.present(alert, animated: true)
                return
            }
            
            if IsSetted {
                switch self.typeOfRegister {
                case .emploee:
                    self.user?.company.addEmployeeToCompany(token: self.user?.getToken() ?? "", completion: { isAdded, error in
                        if error != nil
                        
                        
                        {
                            return
                        }
                        if isAdded{
                            self.goToMainTabBar()
                        }
                        
                    })
                    
                case .company:
                    self.user?.company.setCompanyNameApi(token: self.user?.getToken() ?? "", completion: { isAdded, error in
                        if error != nil{
                            self.goToLogInPage()
                            return
                        }
                        if isAdded{
                            self.goToMainTabBar()
                        }
                    })
                }
                
            }
        })

    }
    
    // MARK: - Navigation
    
    fileprivate func goToMainTabBar(){
        let mainTabBar = self.controllers.getControllerMain(.mainTabBarController)
        

        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toTop
        options.duration = 0.3
        options.style = .easeIn
        
        window?.set(rootViewController: mainTabBar,options: options)
        
    }
    
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
            self.phoneString = textField.text ?? ""
            tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true)
        }
        
       
    }
}
