//
//  NewExcursionTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.06.2023.
//

import UIKit

class NewExcursionTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    var presenter:NewExcursionPresenterProtocol!
    
    
    @IBOutlet weak var excursionName: UITextField!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var notesLabel: UILabel!
    
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
    let controllers = Controllers()
    let alerts = Alert()
    let validation = StringValidation()
    
    var isUpdate = false
    var oldDate:Date!
    
    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if isUpdate{
            if presenter.isAccessLevel(key: .canWriteTourList){
                self.navigationItem.title = "Редактирование"
            }else{
                self.navigationItem.title = "Просмотр"
            }
           
        }else{
            self.navigationItem.title = "Добавление"
        }
        self.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if presenter.isAccessLevel(key: .canWriteTourList){
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClick))
        }
        
        if presenter.isAccessLevel(key: .canWriteTourList){
            if #available(iOS 16.0, *) {
                self.navigationItem.backAction = UIAction(handler: { _ in
                    if !(self.presenter.isEqualTours()){
                        self.warningAlertDuringExit(isPopController: true)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
               
        configureFieldsWithExcursionInfo()
        guiedsCollectionView.reloadData()
    }
    
    
    
    // MARK: - Configuration Labels
    
    fileprivate func configureFieldsWithExcursionInfo(){
        
        self.excursionName.text = self.presenter.tour.tourTitle
        
        self.routeLabel.text = !self.presenter.tour.route.isEmpty ? self.presenter.tour.route : "Не выбрано"
        
        self.notesLabel.text = self.presenter.tour.notes
        
        self.notesForGuidesSwitch.isOn = self.presenter.tour.guideCanSeeNotes
        
        self.numberOfPeople.text = self.presenter.tour.numberOfPeople
        
        self.customerCompanyNameLabel.text = !self.presenter.tour.customerCompanyName.isEmpty ? self.presenter.tour.customerCompanyName : "Не выбрано"
        
        self.customerGuiedNameLabel.text = !self.presenter.tour.customerGuideName.isEmpty ? self.presenter.tour.customerGuideName : "Не выбрано"
        
        self.customerGuidePhone.text = self.presenter.tour.companyGuidePhone
        
        self.paymentMethodSwitch.setOn(self.presenter.tour.isPaid, animated: false)
        self.paymentMethodLabel.text = !self.presenter.tour.paymentMethod.isEmpty ? self.presenter.tour.paymentMethod : "Не выбрано"
        
        self.paymentAmountTextField.text = self.presenter.tour.paymentAmount
        
        self.dateAndTime.setDate(self.presenter.tour.dateAndTime, animated: true)
        
    }
    
    
    // MARK: - save Button Click
    
    @objc fileprivate func saveButtonClick(){
        if !validation.validateLenghtString(string: self.presenter.tour.tourTitle, min: 1, max: 100){
            self.alerts.validationStringError(self, title: "Ошибка в названии экскурсии",message: "Минимальная длина - 1. Максимальная длина - 100")
            return
        }
        
        if !validation.validateLenghtString(string: self.presenter.tour.notes, max: 1000){
            self.alerts.validationStringError(self, title: "Ошибка в заметках", message: "Максимальная длина - 1000")
            return
        }
        
////        if self.excursion.companyGuidePhone.count > 0 && !validation.validatePhone(value: self.excursion.companyGuidePhone){
//            self.alerts.validationStringError(self, title: "Ошибка в контакте сопровождающего")
//            return
//        }
        
        if !validation.validateNumberWithPlus(value: self.presenter.tour.numberOfPeople){
            self.alerts.validationStringError(self, title: "Ошибка в количестве человек")
            return
        }
        
        if !validation.validateNumberWithPlus(value: self.presenter.tour.paymentAmount){
            self.alerts.validationStringError(self, title: "Ошибка сумме оплаты")
            return
        }
        
        
//        if isUpdate{
//            presenter.updateExcursion()
//        }else{
//            presenter.createNewExcursion()
//        }
    }
    
    // MARK: - Datepicker
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.presenter.tour.dateAndTime = sender.date
        
    }
    
    // MARK: - IsPaid
    
    @IBAction func isPaidAction(_ sender: UISwitch) {
        self.presenter.tour.isPaid = sender.isOn
    }
    
    @IBAction func notesForGuidesSwitch(_ sender: UISwitch) {
        self.presenter.tour.guideCanSeeNotes = sender.isOn
    }
    
    // MARK: - delete Excursion
    @IBAction func deleteExcursionTap(_ sender: Any) {
        
        self.alerts.deleteAlert(self, title: "Вы уверены что хотите удалить экскурсию?", buttonTitle: "Удалить") {
            self.presenter.deleteTour()
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
        
        if !presenter.isAccessLevel(key: .canWriteTourList) && !(indexPath.section == 3 && indexPath.row == 1){
            cell.isUserInteractionEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                
        if indexPath.section == 0 && indexPath.row == 1{
            let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .route, baseValue: self.presenter.tour.route) as! AddingNewComponentViewController
            
            newComponentVC.doAfterClose = { value in
                self.presenter.tour.route = value
            }
            
            self.navigationController?.pushViewController(newComponentVC, animated: true)
            
        }else if indexPath.section == 0 && indexPath.row == 5{
            
            let notesVC = NotesViewController()
            notesVC.textView.text = self.presenter.tour.notes
            notesVC.doAfterClose = { notes in
                self.presenter.tour.notes = notes
                self.notesLabel.text = notes
            }
            
            self.navigationController?.pushViewController(notesVC, animated: true)
            
        }else if
            indexPath.section == 1 && indexPath.row == 0{
            let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .customerCompanyName, baseValue: self.presenter.tour.customerCompanyName) as! AddingNewComponentViewController
            
            newComponentVC.doAfterClose = { value in
                self.presenter.tour.customerCompanyName = value
            }

            self.navigationController?.pushViewController(newComponentVC, animated: true)
        } else if
            indexPath.section == 1 && indexPath.row == 1{
            
            let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .customerGuiedName, baseValue: self.presenter.tour.customerGuideName) as! AddingNewComponentViewController
            
            newComponentVC.doAfterClose = { value in
                self.presenter.tour.customerGuideName = value
            }

            self.navigationController?.pushViewController(newComponentVC, animated: true)
        }else if indexPath.section == 2 && indexPath.row == 1 {
            
            let newComponentVC = TourManadmentAssembly.createAutoFillComponentsController(type: .excursionPaymentMethod, baseValue: self.presenter.tour.paymentMethod) as! AddingNewComponentViewController
            
            newComponentVC.doAfterClose = { value in
                self.presenter.tour.paymentMethod = value
            }
            
            self.navigationController?.pushViewController(newComponentVC, animated: true)
            
        }
        else if indexPath.section == 3 && indexPath.row == 0{
            
            let selectGuidesVC = TourManadmentAssembly.createAddGuideController(selectedGuides: self.presenter.tour.guides) as! AddGuideViewController
            
            selectGuidesVC.doAfterClose = {guides in
                self.presenter.tour.guides = guides
                self.guiedsCollectionView.reloadData()
            }

            self.navigationController?.pushViewController(selectGuidesVC, animated: true)
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
            self.presenter.tour.tourTitle = textField.text ?? ""
        }
        else if textField.restorationIdentifier == "numberOfPeople"{
            
            var newNumberOfPeople = (textField.text ?? "0").replacingOccurrences(of: " ", with: "")
            
            newNumberOfPeople = newNumberOfPeople == "" ? "0" : newNumberOfPeople

            self.presenter.tour.numberOfPeople = newNumberOfPeople
            textField.text = newNumberOfPeople
        } else if textField.restorationIdentifier == "customerGuidePhone"{
            let newPhone = textField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "‑", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: " ", with: "") ?? ""
            
            textField.text = newPhone
            
            self.presenter.tour.companyGuidePhone = newPhone
            
        }else if textField.restorationIdentifier == "amount"{
            
            
            var newAmount = (textField.text ?? "0").replacingOccurrences(of: " ", with: "")
            
            newAmount = newAmount == "" ? "0" : newAmount
            self.presenter.tour.paymentAmount = newAmount
            textField.text = newAmount
        }
    }
}

// MARK: - UITextViewDelegate
extension NewExcursionTableViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        self.presenter.tour.notes = textView.text
    }
}


// MARK: - UICollectionViewDelegate
extension NewExcursionTableViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.tour.guides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nib = UINib(nibName: "GuideCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GuideCollectionViewCell")
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        
        let guide = self.presenter.tour.guides[indexPath.row]
        
        cell.fullName.text = guide.firstName + " " + guide.lastName
        if guide.isMain{
            cell.isMainGuide.isHidden = false
        }else{
            cell.isMainGuide.isHidden = true
        }
            
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
        
//        guideController.employee = self.excursion.selfGuides[indexPath.row].guideInfo
//        guideController.isShowAccessLevels = false
        
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
        if !(self.presenter.isEqualTours()){
            warningAlertDuringExit(isPopController: true)
            return false
        }
            
       
        return true
    }
}

extension NewExcursionTableViewController:NewExcursionViewProtocol{
    func refreshSuccess() {
        
    }
    
    func validationError(title: String, msg: String) {
        
    }
    
    func fillGuides() {
        
    }
    
    func fillFields() {
        
    }
    
    
    func updateCollectionView() {
        self.guiedsCollectionView.reloadData()
    }
    
    
    func isUpdated(isSuccess: Bool) {
        if isSuccess{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func isAdded(isSuccess: Bool) {
        if isSuccess{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func delete(isSuccess: Bool) {
        if isSuccess{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
