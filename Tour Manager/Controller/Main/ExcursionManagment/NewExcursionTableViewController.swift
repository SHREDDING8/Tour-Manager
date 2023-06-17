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
    
    
    // MARK: - Objects
    
    var darkUiView:UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .black
        uiView.layer.opacity = 0
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    var pickerPaymentMethodView:UIView = {
        let view = UIView()
        
        let picker = UIPickerView()
        
        return view
    }()
    
    
    
    // MARK: - my variables
    
    let user = AppDelegate.user
    
    let excursionModel = ExcursionsControllerModel()
    
    
    var excursion = Excursion()
    let controllers = Controllers()
    
    var isUpdate = false
    var oldDate:Date!
    
    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClick))
        if isUpdate{
            self.navigationItem.title = "Редактирование"
            self.oldDate = excursion.dateAndTime
        }else{
            self.navigationItem.title = "Добавление"
        }
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureFieldsWithExcursionInfo()
    }
    
    // MARK: - Configuration Labels
    
    fileprivate func configureFieldsWithExcursionInfo(){
        
        self.excursionName.text = self.excursion.excursionName
        
        self.routeLabel.text = !self.excursion.route.isEmpty ? self.excursion.route : "Не выбрано"
        
        self.additionalInformation.text = self.excursion.additionalInfromation
        
        self.numberOfPeople.text = String(self.excursion.numberOfPeople)
        
        self.customerCompanyNameLabel.text = !self.excursion.customerCompanyName.isEmpty ? self.excursion.customerCompanyName : "Не выбрано"
        
        self.customerGuiedNameLabel.text = !self.excursion.customerGuideName.isEmpty ? self.excursion.customerGuideName : "Не выбрано"
        
        self.customerGuidePhone.text = self.excursion.companyGuidePhone
        
        self.paymentMethodSwitch.setOn(self.excursion.isPaid, animated: false)
        self.paymentAmountTextField.text = String(self.excursion.paymentAmount)
        
        self.dateAndTime.setDate(excursion.dateAndTime, animated: true)
        
        self.excursion.dateAndTime = self.dateAndTime.date
    }
    
    
    // MARK: - save Button Click
    
    @objc fileprivate func saveButtonClick(){
        if isUpdate{
            excursionModel.updateExcursion(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", excursion: excursion, oldDate: self.oldDate) { isUpdated, error in
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            excursionModel.createNewExcursion(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", excursion: excursion) { isAdded, error in
                if isAdded{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    @IBAction func testTap(_ sender: Any) {
    }
    
    
    
    
    // MARK: - Datepicker
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.excursion.dateAndTime = sender.date
        
    }
    
    // MARK: - IsPaid
    
    @IBAction func isPaidAction(_ sender: UISwitch) {
        self.excursion.isPaid = sender.isOn
    }
    
    
    @IBAction func newGuideTap(_ sender: Any) {
        let destinantion = controllers.getControllerMain(.addingNewComponentViewController) as! AddingNewComponentViewController
        destinantion.excursion = excursion
        destinantion.typeOfNewComponent = .guides
        self.navigationController?.pushViewController(destinantion, animated: true)
    }
}

// MARK: - Table View

extension NewExcursionTableViewController{
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section{
        case 0:
            return 5
        case 1:
            return 3
        case 2: return 3
        case 3: return 1
        
        default: return 0
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
            self.excursion.numberOfPeople = Int(textField.text!) ?? 0
        } else if textField.restorationIdentifier == "customerGuidePhone"{
            self.excursion.companyGuidePhone = customerGuidePhone.text!
        }else if textField.restorationIdentifier == "amount"{
            self.excursion.paymentAmount = Int(textField.text ?? "0") ?? 0
        }
    }
}

extension NewExcursionTableViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        self.excursion.additionalInfromation = textView.text
    }
}


// MARK: - UICollectionViewDelegate
extension NewExcursionTableViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guiedCollectionViewCell", for: indexPath)
        
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        
//        let cellWidth = 200
//        let cellCount = 1
//        let cellSpacing = 10
//
//        let totalCellWidth = cellWidth * cellCount
//        let totalSpacingWidth = cellSpacing * (cellCount - 1)
//
//        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//
//        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
//        let cellWidth = 200
//        let cellCount = 1
//        let cellSpacing = 10
//
//        let totalCellWidth = cellWidth * cellCount
//        let totalSpacingWidth = cellSpacing * (cellCount - 1)
//
//        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//        
//        return rightInset
        
        return 0
    }
}

