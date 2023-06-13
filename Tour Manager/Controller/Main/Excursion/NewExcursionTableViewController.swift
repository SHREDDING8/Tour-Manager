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
    
    @IBOutlet weak var guiedsCollectionView: UICollectionView!
    
    
    
    // MARK: - my variables
    
    let user = AppDelegate.user
    
    let excursionModel = ExcursionsControllerModel()
    
    
    var excursion = Excursion()
    let controllers = Controllers()
    
    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.excursion.dateAndTime = self.dateAndTime.date
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClick))
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
        
    }
    
    
    // MARK: - save Button Click
    
    @objc fileprivate func saveButtonClick(){
        
        excursionModel.createNewExcursion(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", excursion: excursion) { isAdded, error in
            if isAdded{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
    // MARK: - Datepicker
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.excursion.dateAndTime = sender.date
        
    }
}

// MARK: - Table View

extension NewExcursionTableViewController{
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section{
        case 0:
            return 6
        case 1:
            return 3
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cellWidth = 200
        let cellCount = 1
        let cellSpacing = 10

        let totalCellWidth = cellWidth * cellCount
        let totalSpacingWidth = cellSpacing * (cellCount - 1)

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let cellWidth = 200
        let cellCount = 1
        let cellSpacing = 10

        let totalCellWidth = cellWidth * cellCount
        let totalSpacingWidth = cellSpacing * (cellCount - 1)

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return rightInset
    }
}

