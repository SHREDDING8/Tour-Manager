//
//  AddingPersonalDataViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit
import AlertKit


class AddingPersonalDataViewController: BaseViewController {
    
    var presenter: AddingPersonalDataPresenterProtocol!
    
    
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
    
    
    var typeOfRegister:TypeOfRegister = .company
    
    // MARK: - Life Cycle
    private func view() -> SetInfoView{
        return view as! SetInfoView
    }
    
    override func loadView() {
        super.loadView()
        self.view = SetInfoView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleString = "Личная информация"
        self.setBackButton()
        
        self.presenter.model.birthday = Date.now.birthdayToString()
        
        addDelegates()
        addTargets()
        
        switch presenter.type {
        case .newCompany:
            self.view().company.elementLabel.text = "Название организации"
            self.view().company.textField.placeholder = "Введите название"
        case .newEmployee:
            self.view().company.elementLabel.text = "Идентификатор организации"
            self.view().company.textField.placeholder = "Введите идентификатор"
        }
    }
    
    func addDelegates(){
        self.view().company.textField.delegate = self
        self.view().name.textField.delegate = self
        self.view().secondName.textField.delegate = self
        self.view().birthday.textField.delegate = self
        self.view().phone.textField.delegate = self
    }
    
    func addTargets(){
        self.view().continueButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    
    @objc func buttonTapped(){
        presenter.buttonTapped()
    }
    
    
    // MARK: - SetPersonalData in to Server
    
    @IBAction func setPersonalDataTapped(_ sender: Any) {
                
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
    }
    
}


// MARK: - UITextFieldDelegate

extension AddingPersonalDataViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        switch textField.restorationIdentifier{
        case "company":
            presenter.model.company = textField.text ?? ""
        case "name":
            presenter.model.firstName = textField.text ?? ""
        case "secondName":
            presenter.model.secondName = textField.text ?? ""
        case "birthday":
            presenter.model.birthday = textField.text ?? ""
        case "phone":
            presenter.model.phone = textField.text ?? ""
        default: fatalError("Unknown TextField")
            
        }
    }
}

extension AddingPersonalDataViewController:AddingPersonalDataViewProtocol{
    func successful() {
        MainAssembly.goToMainTabBar(view: self.view)
    }
    
    func validationError(msg: String) {
        AlertKitAPI.present(
            title: msg,
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
}
