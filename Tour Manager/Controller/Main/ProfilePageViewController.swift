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
    
    let user = AppDelegate.user!
    let controllers = Controllers()
    let profileModel = Profile()
    
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
        
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
//            print(self.datePickerUiView.frame)
//        })
        
        configurationView()
        
        addSubviews()
        
        profilePhotoConfiguration()
        configurationDarkUiView()
        datePickerConfiguration()
        
        AppDelegate.user!.printData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewPosition = tableView.frame.origin
    
    }
    
    // MARK: - Configuration
    
    fileprivate func configurationView(){
        if self.user.getAccessLevel(rule: .readGeneralCompanyInformation){
            self.navigationItem.title = self.user.getNameCompany()
        }
        self.fullNameLabel.text = "\(self.user.getFirstName()) \(self.user.getSecondName())"
        
        
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
    
    
    // MARK: - Button Taps
    
    
    
    // MARK: - Navigation
    fileprivate func goToLogInPage(){
        let mainLogIn = self.controllers.getControllerAuth(.mainAuthController)
        
        let window = self.view.window
        let options = UIWindow.TransitionOptions()
        
        options.direction = .toBottom
        options.duration = 0.3
        options.style = .easeOut
        
        window?.set(rootViewController: mainLogIn,options: options)
        
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
    
}

// MARK: - ProfilePageViewController
extension ProfilePageViewController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
        case 1: title.text = "Компания"
//        case 2: title.text = ""
        default: title.text = ""
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0: return 6
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section{
        case 0:
            cell = getPersonalDataCell(indexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
            
            let button = cell.viewWithTag(1) as! UIButton
            let actionExit = UIAction { _ in
                self.goToLogInPage()
            }
            
            button.addAction(actionExit, for: .touchUpInside)
                        
            return cell
        default:
            break
        }
        
        let index = indexPath.section == 0 ? indexPath.row : indexPath.row + 7
        
//        let cellType:CellTypeProfilePage = CellTypeProfilePage(index: index)!
        
//        switch index{
//
//        case 6...8:
//            cell = tableView.dequeueReusableCell(withIdentifier: "otherPagesCell", for: indexPath)
//            let cellLabel:UILabel = cell.viewWithTag(2) as! UILabel
//            cellLabel.text = cellType.rawValue.0
//        default:
//            return UITableViewCell()
//        }
        
        return cell
    }
    
    fileprivate func getPersonalDataCell(indexPath:IndexPath) -> UITableViewCell{
        var cell = UITableViewCell()
        let cellType = profileModel.getProfileCellType(index: indexPath.row)
        
        switch indexPath.row{
        case 0...1, 3...4:
            cell = tableView.dequeueReusableCell(withIdentifier: "profileSettingsCell", for: indexPath)
            
            
            
            
            let textField:UITextField = cell.viewWithTag(2) as! UITextField
            textField.text = profileModel.getProfilePersonalDataFromUser(type: cellType)
            
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
            
        default:
            break
        }
        
        return cell
        
    }
}

extension ProfilePageViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
