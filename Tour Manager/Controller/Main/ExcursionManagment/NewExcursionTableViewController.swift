//
//  NewExcursionTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.06.2023.
//

import UIKit

class NewExcursionTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var excursionName: UITextField!
    
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var additionalInformation: UITextView!{
        didSet{
            additionalInformation.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var notesForGuidesSwitch: UISwitch!
    
    
    
    @IBOutlet weak var dateAndTime: UIDatePicker!
    
    @IBOutlet weak var numberOfPeople: UITextField!{
        didSet{
            numberOfPeople.addDoneCancelToolbar()
        }
    }
    

    
    @IBOutlet weak var customerCompanyNameLabel: UILabel!
    
    
    @IBOutlet weak var customerGuiedNameLabel: UILabel!
    
    @IBOutlet weak var customerGuidePhone: UITextField!
    
    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    @IBOutlet weak var paymentAmountTextField: UITextField!{
        didSet{
            paymentAmountTextField.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var paymentMethodSwitch: UISwitch!
    
    @IBOutlet weak var guiedsCollectionView: UICollectionView!
    
    // MARK: - my variables
    
    let user = AppDelegate.user
    
    let excursionModel = ExcursionsControllerModel()
    
    
    var excursion = Excursion()
    var oldTour = Excursion()
    let controllers = Controllers()
    let alerts = Alert()
    let validation = StringValidation()
    
    var isUpdate = false
    var oldDate:Date!
    
    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oldTour = excursion.copy()
        
        if (self.user?.getAccessLevel(rule: .canWriteTourList) ?? false){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClick))
        }
        
        if (self.user?.getAccessLevel(rule: .canWriteTourList) ?? false){
            if #available(iOS 16.0, *) {
                self.navigationItem.backAction = UIAction(handler: { _ in
                    if !(self.oldTour == self.excursion){
                        self.warningAlertDuringExit(isPopController: true)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
        
        
       
        if isUpdate{
            if (self.user?.getAccessLevel(rule: .canWriteTourList) ?? false){
                self.navigationItem.title = "Редактирование"
            }else{
                self.navigationItem.title = "Просмотр"
            }
           
            self.oldDate = excursion.dateAndTime
        }else{
            self.navigationItem.title = "Добавление"
        }
        self.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.user?.getAccessLevel(rule: .canWriteTourList) ?? false){
            self.navigationController?.interactivePopGestureRecognizer?.delegate! = self
        }
       
        configureFieldsWithExcursionInfo()
        guiedsCollectionView.reloadData()
    }
    
    // MARK: - Configuration Labels
    
    fileprivate func configureFieldsWithExcursionInfo(){
        
        self.excursionName.text = self.excursion.excursionName
        
        self.routeLabel.text = !self.excursion.route.isEmpty ? self.excursion.route : "Не выбрано"
        
        self.additionalInformation.text = self.excursion.additionalInfromation
        
        self.notesForGuidesSwitch.isOn = self.excursion.guideAccessNotes
        
        self.numberOfPeople.text = String(self.excursion.numberOfPeople)
        
        self.customerCompanyNameLabel.text = !self.excursion.customerCompanyName.isEmpty ? self.excursion.customerCompanyName : "Не выбрано"
        
        self.customerGuiedNameLabel.text = !self.excursion.customerGuideName.isEmpty ? self.excursion.customerGuideName : "Не выбрано"
        
        self.customerGuidePhone.text = self.excursion.companyGuidePhone
        
        self.paymentMethodSwitch.setOn(self.excursion.isPaid, animated: false)
        self.paymentMethodLabel.text = !self.excursion.paymentMethod.isEmpty ? self.excursion.paymentMethod : "Не выбрано"
        self.paymentAmountTextField.text = String(self.excursion.paymentAmount)
        
        self.dateAndTime.setDate(excursion.dateAndTime, animated: true)
        
        self.excursion.dateAndTime = self.dateAndTime.date
    }
    
    
    // MARK: - save Button Click
    
    @objc fileprivate func saveButtonClick(){
        if !validation.validateLenghtString(string: self.excursion.excursionName, min: 1, max: 100){
            self.alerts.validationStringError(self, title: "Ошибка в названии экскурсии",message: "Минимальная длина - 1. Максимальная длина - 100")
            return
        }
        
        if !validation.validateLenghtString(string: self.excursion.additionalInfromation, max: 1000){
            self.alerts.validationStringError(self, title: "Ошибка в заметках", message: "Максимальная длина - 1000")
            return
        }
        
        if self.excursion.companyGuidePhone.count > 0 && !validation.validatePhone(value: self.excursion.companyGuidePhone){
            self.alerts.validationStringError(self, title: "Ошибка в контакте сопровождающего")
            return
        }
        
        if !validation.validateNumberWithPlus(value: self.excursion.numberOfPeople){
            self.alerts.validationStringError(self, title: "Ошибка в количестве человек")
            return
        }
        
        if !validation.validateNumberWithPlus(value: self.excursion.paymentAmount){
            self.alerts.validationStringError(self, title: "Ошибка сумме оплаты")
            return
        }
        
        
        
        
        
        if isUpdate{
            excursionModel.updateExcursion(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", excursion: excursion, oldDate: self.oldDate) { isUpdated, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                if isUpdated{
                    self.navigationController?.popViewController(animated: true)
                }
               
            }
        }else{
            excursionModel.createNewExcursion(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", excursion: excursion) { isAdded, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                if isAdded{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    // MARK: - Datepicker
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.excursion.dateAndTime = sender.date
        
    }
    
    // MARK: - IsPaid
    
    @IBAction func isPaidAction(_ sender: UISwitch) {
        self.excursion.isPaid = sender.isOn
    }
    
    @IBAction func notesForGuidesSwitch(_ sender: UISwitch) {
        self.excursion.guideAccessNotes = sender.isOn
    }
    
    @IBAction func deleteExcursionTap(_ sender: Any) {
        
        self.alerts.deleteAlert(self, title: "Вы уверены что хотите удалить экскурсию?", buttonTitle: "Удалить") {
            self.excursionModel.deleteExcursion(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", excursion: self.excursion) { isDeleted, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorExcursionsApi: err)
                }
                if isDeleted{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

// MARK: - Table View

extension NewExcursionTableViewController{
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var returnCount = 0
        self.isUpdate ? (returnCount = 5) : (returnCount = 4)
        
        return returnCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section{
        case 0:
            return 6
        case 1:
            return 3
        case 2: return 3
        case 3: return 2
            
        case 4: return 1
        
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !(self.user?.getAccessLevel(rule: .canWriteTourList) ?? false) && !(indexPath.section == 3 && indexPath.row == 1){
            cell.isUserInteractionEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                
        let destinantion = controllers.getControllerMain(.addingNewComponentViewController) as! AddingNewComponentViewController
        destinantion.excursion = excursion
        
        if indexPath.section == 0 && indexPath.row == 1{
            destinantion.typeOfNewComponent = .route
            self.navigationController?.pushViewController(destinantion, animated: true)
        } else if
            indexPath.section == 1 && indexPath.row == 0{
            destinantion.typeOfNewComponent = .customerCompanyName

            self.navigationController?.pushViewController(destinantion, animated: true)
        } else if
            indexPath.section == 1 && indexPath.row == 1{
            destinantion.typeOfNewComponent = .customerGuiedName

            self.navigationController?.pushViewController(destinantion, animated: true)
        }else if indexPath.section == 2 && indexPath.row == 1 {
            destinantion.typeOfNewComponent = .excursionPaymentMethod

            self.navigationController?.pushViewController(destinantion, animated: true)
            
        }
        else if indexPath.section == 3 && indexPath.row == 0{
            destinantion.typeOfNewComponent = .guides

            self.navigationController?.pushViewController(destinantion, animated: true)
        }
    }
}


// MARK: - UITextFieldDelegate
extension NewExcursionTableViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.restorationIdentifier == "excursionName"{
            self.excursion.excursionName = textField.text ?? ""
        }
        else if textField.restorationIdentifier == "numberOfPeople"{
            
            var newNumberOfPeople = (textField.text ?? "0").replacingOccurrences(of: " ", with: "")
            
            newNumberOfPeople = newNumberOfPeople == "" ? "0" : newNumberOfPeople

            self.excursion.numberOfPeople = newNumberOfPeople
            textField.text = newNumberOfPeople
        } else if textField.restorationIdentifier == "customerGuidePhone"{
            
            let newPhone = textField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "") ?? ""
            
            textField.text = newPhone
            
            self.excursion.companyGuidePhone = newPhone
            
        }else if textField.restorationIdentifier == "amount"{
            
            var newAmount = (textField.text ?? "0").replacingOccurrences(of: " ", with: "")
            
            newAmount = newAmount == "" ? "0" : newAmount
            self.excursion.paymentAmount =  newAmount
            textField.text = newAmount
        }
    }
}

// MARK: - UITextViewDelegate
extension NewExcursionTableViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        self.excursion.additionalInfromation = textView.text
    }
}


// MARK: - UICollectionViewDelegate
extension NewExcursionTableViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.excursion.selfGuides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nib = UINib(nibName: "GuideCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GuideCollectionViewCell")
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        
        cell.fullName.text = self.excursion.selfGuides[indexPath.row].guideInfo.getFullName()
        if self.excursion.selfGuides[indexPath.row].isMain{
            cell.isMainGuide.isHidden = false
        }else{
            cell.isMainGuide.isHidden = true
        }
                
        cell.status.tintColor = self.excursion.selfGuides[indexPath.row].status.getColor()
        
        self.user?.downloadProfilePhoto(localId: self.excursion.selfGuides[indexPath.row].guideInfo.getLocalID() ?? "", completion: { data, error in
            if data != nil{
                UIView.transition(with: cell.profilePhoto, duration: 0.3, options: .transitionCrossDissolve) {
                    cell.profilePhoto.image = UIImage(data: data!)!
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let guideController = self.controllers.getControllerMain(.employeeViewController) as! EmploeeViewController
        
        guideController.employee = self.excursion.selfGuides[indexPath.row].guideInfo
        guideController.isShowAccessLevels = false
        
        self.navigationController?.pushViewController(guideController, animated: true)
        
        
    }
    
}

// MARK: - Alerts
extension NewExcursionTableViewController{
    fileprivate func warningAlertDuringExit(isPopController:Bool){
        let warningAlert = self.alerts.warningAlert(title: "Возможно у вас есть несохраненные данные", meesage: "Вы уверены что хотите выйти?", actionTitle: "Выйти") {
            if isPopController{
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        self.present(warningAlert, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension NewExcursionTableViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !(oldTour == excursion){
            warningAlertDuringExit(isPopController: true)
            return false
        }
            
       
        return true
    }
}

