//
//  AddingNewComponentViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 13.06.2023.
//

import UIKit

enum TypeOfNewComponent{
    case route
    case customerCompanyName
    case customerGuiedName
    case excursionPaymentMethod
    
    case guides
    
}

class AddingNewComponentViewController: UIViewController {
    
    // MARK: - My variables
    
    var excursion:Excursion!
    
    let alerts = Alert()
    
    let excursionsModel = ExcursionsControllerModel()
    
    let user = AppDelegate.user
    
    var fullArrayComponents:[String] = []
    
    var fullArrayWithGuides:[SelfGuide] = []
    
    var arrayComponents:[String] = []
    
    var arrayWithGuides:[SelfGuide] = []
        
    // MARK: - Objects
    
    var textField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var line:UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .orange
        line.layer.cornerRadius = 5
        line.layer.opacity = 0.5
        return line
    }()
    
    
    var typeOfNewComponent:TypeOfNewComponent = .route

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        addSubviews()
        configureTextFieldAndLine()
        configureTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch typeOfNewComponent {
        case .route:
            excursionsModel.addAutofill(token: self.user?.getToken() ?? "" , companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionRoute, autofillValue: self.excursion.route) { isAdded, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                
            }
        case .customerCompanyName:
            excursionsModel.addAutofill(token: self.user?.getToken() ?? "" , companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionCustomerCompanyName, autofillValue: self.excursion.customerCompanyName) { isAdded, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                
            }
        case .customerGuiedName:
            excursionsModel.addAutofill(token: self.user?.getToken() ?? "" , companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionCustomerGuideContact, autofillValue: self.excursion.customerGuideName) { isAdded, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                
            }
        case .excursionPaymentMethod:
            excursionsModel.addAutofill(token: self.user?.getToken() ?? "" , companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionPaymentMethod, autofillValue: self.excursion.paymentMethod) { isAdded, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                
            }
            
        case .guides:
            break
        }
        
    }
    
    
    // MARK: - configuration
    
    fileprivate func configureView(){
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate? = self
        if typeOfNewComponent != .guides{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))
        }
        
        self.textField.addTarget(self, action: #selector(getNewHint), for: .editingChanged)
        
        
        switch typeOfNewComponent{
            
        case .route:
            self.title = "Маршрут"
            textField.placeholder = "Маршрут"
            textField.text = excursion.route
            
            excursionsModel.getAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionRoute) { isGetted, values, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                if isGetted{
                    self.arrayComponents = values!
                    self.fullArrayComponents = self.arrayComponents
                    self.tableView.reloadData()
                }
            }
        case .customerCompanyName:
            self.title = "Название компании"
            textField.placeholder = "Название компании"
            textField.text = excursion.customerCompanyName
            excursionsModel.getAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionCustomerCompanyName) { isGetted, values, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                if isGetted{
                    self.arrayComponents = values!
                    self.fullArrayComponents = self.arrayComponents
                    self.tableView.reloadData()
                }
            }
        case .customerGuiedName:
            self.title = "ФИО сопровождающего"
            textField.placeholder = "ФИО сопровождающего"
            textField.text = excursion.customerGuideName
            excursionsModel.getAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionCustomerGuideContact) { isGetted, values, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                if isGetted{
                    self.arrayComponents = values!
                    self.fullArrayComponents = self.arrayComponents
                    self.tableView.reloadData()
                }
            }
            
        case .excursionPaymentMethod:
            self.title = "Способ оплаты"
            textField.placeholder = "Способ оплаты"
            textField.text = excursion.paymentMethod
            
            excursionsModel.getAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionPaymentMethod) { isGetted, values, error in
                if let err = error{
                    self.alerts.errorAlert(self, errorAutoFillApi: err)
                }
                if isGetted{
                    self.arrayComponents = values!
                    self.fullArrayComponents = self.arrayComponents
                    self.tableView.reloadData()
                }
            }
            
            
        case .guides:
            self.title = "Экскурсоводы"
            textField.placeholder = "Найти"
            
            self.user?.company.getCompanyGuides(token: self.user?.getToken() ?? "", completion: { isGetted, guides, error in
                
                if let err = error{
                    self.alerts.errorAlert(self, errorCompanyApi: err)
                }
                
                if isGetted{
                    for guide in guides!{
                        let newGuide = SelfGuide(guideInfo: guide, isMain: false)
                        self.arrayWithGuides.append(newGuide)
                    }
                    self.fullArrayWithGuides = self.arrayWithGuides
                    self.tableView.reloadData()
                    
                    if self.fullArrayWithGuides.count > 0{
                        self.showContextualAction(cell: self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NewComponentTableViewCell)
                    }
                    
                }
            })
        }
    }
    
    // MARK: - addSubviews
    
    fileprivate func addSubviews(){
        self.view.addSubview(self.textField)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.line)
    }
    
    // MARK: - configureTextField
    
    fileprivate func configureTextFieldAndLine(){
        textField.font = Font.getFont(name: .americanTypewriter, style: .bold, size: 24)
        
        textField.delegate = self
        
        
        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),

            self.textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            self.textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            self.textField.heightAnchor.constraint(equalToConstant: 50),
            
            self.line.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 2),
            self.line.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.line.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.line.heightAnchor.constraint(equalToConstant: 2)
        ])
        
    }
    
    // MARK: - Configure Table View
    
    fileprivate func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: line.bottomAnchor,constant: 30),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let nibcell = UINib(nibName: "NewComponentTableViewCell", bundle: nil)
        tableView.register(nibcell, forCellReuseIdentifier: "NewComponentTableViewCell")
    }
    

}

// MARK: - UITextFieldDelegate
extension AddingNewComponentViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch typeOfNewComponent{
        case .route:
            self.excursion.route = textField.text ?? ""
        case .customerCompanyName:
            self.excursion.customerCompanyName = textField.text ?? ""
        case .customerGuiedName:
            self.excursion.customerGuideName = textField.text ?? ""
        
        case .excursionPaymentMethod:
            self.excursion.paymentMethod = textField.text ?? ""
            
        case .guides:
            break
        }
    }
    
    
    @objc func getNewHint(){
        if typeOfNewComponent != .guides{
            self.arrayComponents = []
            if !self.textField.hasText{
                self.arrayComponents = fullArrayComponents
                UIView.transition(with: self.tableView, duration: 0.2,options: .transitionCrossDissolve) {
                    self.tableView.reloadData()
                }
                return
            }
                for hint in fullArrayComponents{
                    if hint.lowercased().contains(self.textField.text!.lowercased()){
                        arrayComponents.append(hint)
                    }
                }
                UIView.transition(with: self.tableView, duration: 0.2,options: .transitionCrossDissolve) {
                    self.tableView.reloadData()
                }
            return
            
        }
        
        self.arrayWithGuides = []
        
        if !self.textField.hasText{
            self.arrayWithGuides = self.fullArrayWithGuides
            UIView.transition(with: self.tableView, duration: 0.2,options: .transitionCrossDissolve) {
                self.tableView.reloadData()
            }
            return
        }
        
        for hint in fullArrayWithGuides{
            if hint.guideInfo.getFullName().lowercased().contains(self.textField.text!.lowercased()){
                arrayWithGuides.append(hint)
            }
        }
        UIView.transition(with: self.tableView, duration: 0.2,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    return
    }
}


// MARK: - Table View
extension AddingNewComponentViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if typeOfNewComponent == .guides{
            return self.arrayWithGuides.count
        }
        return self.arrayComponents.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if typeOfNewComponent != .guides{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewComponentTableViewCell") as! NewComponentTableViewCell
            cell.componentText.text = arrayComponents[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewComponentTableViewCell") as! NewComponentTableViewCell
        cell.componentText.text = arrayWithGuides[indexPath.row].guideInfo.getFullName()
        
        for guide in excursion.selfGuides{
            
            if arrayWithGuides[indexPath.row].guideInfo == guide.guideInfo{
                cell.accessoryType = .checkmark
            }
        }
        
        
        return cell
    }
    
    fileprivate func showContextualAction(cell:NewComponentTableViewCell){
        
        let uiView = UIView(frame: CGRect(origin: CGPoint(x: cell.componentText.frame.origin.x + 5, y: cell.frame.origin.y) , size: CGSize(width: 100, height: cell.frame.height)))
        
        uiView.backgroundColor = .systemGreen
        uiView.layer.cornerRadius = cell.layer.cornerRadius
        
        self.tableView.addSubview(uiView)
        self.tableView.sendSubviewToBack(uiView)
        
        
        UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform(translationX: 50, y: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        

            if typeOfNewComponent == .guides{
            
            let cell = tableView.cellForRow(at: indexPath)
            
            if cell?.accessoryType != .checkmark{
                cell?.accessoryType = .checkmark
                
                excursion.selfGuides.append(self.arrayWithGuides[indexPath.row])
                
                if excursion.selfGuides.count == 1{
                    excursion.selfGuides[0].isMain = true
                }
            }else{
                cell?.accessoryType = .none
                
                let unselectedGuide = self.arrayWithGuides[indexPath.row]
                
                for indexGuide in 0..<excursion.selfGuides.count{
                    
                    if unselectedGuide.guideInfo == excursion.selfGuides[indexGuide].guideInfo{
                        excursion.selfGuides.remove(at: indexGuide)
                            break
                    }
                }
            }
            
            return
        }
        
        self.textField.text = (tableView.cellForRow(at: indexPath) as! NewComponentTableViewCell).componentText.text
        
        self.textFieldDidEndEditing(self.textField)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if typeOfNewComponent == .guides{
            return true
        }
        
        if tableView.isEditing{
            self.navigationItem.rightBarButtonItem!.title = "Done"
        }else{
            self.navigationItem.rightBarButtonItem!.title = "Edit"
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if typeOfNewComponent != .guides{
            return nil
        }
         
        let mainGuideAction = UIContextualAction(style: .destructive, title: "Главный гид") {  (contextualAction, view, boolValue) in
            
            for guide in 0..<self.excursion.selfGuides.count{
                if self.excursion.selfGuides[guide] == self.arrayWithGuides[indexPath.row]{
                    self.excursion.selfGuides[guide].isMain = true
                }else{
                    self.excursion.selfGuides[guide].isMain = false
                }
            }
            
            boolValue(true)
            }
        mainGuideAction.backgroundColor = .systemGreen
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [mainGuideAction])
        
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if typeOfNewComponent == .guides{
            return .none
        }
        return .delete
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if typeOfNewComponent == .guides {
            return
        }
        
        if editingStyle == .delete{
            
            
            switch typeOfNewComponent{
                
            case .route:
                self.excursionsModel.deleteAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionRoute, autofillValue: arrayComponents[indexPath.row]) { isDeleted, error in
                    if let err = error{
                        self.alerts.errorAlert(self, errorAutoFillApi: err)
                    }
                    if isDeleted{
                        self.arrayComponents.remove(at: indexPath.row)
                        
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    
                }
            case .customerCompanyName:
                self.excursionsModel.deleteAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionCustomerCompanyName, autofillValue: arrayComponents[indexPath.row]) {
                    isDeleted, error in
                    
                    if let err = error{
                        self.alerts.errorAlert(self, errorAutoFillApi: err)
                    }
                    
                    if isDeleted{
                        self.arrayComponents.remove(at: indexPath.row)
                        
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    
                }
            case .customerGuiedName:
                self.excursionsModel.deleteAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionCustomerGuideContact, autofillValue: arrayComponents[indexPath.row]) { isDeleted, error in
                    
                    if let err = error{
                        self.alerts.errorAlert(self, errorAutoFillApi: err)
                    }
                    
                    if isDeleted{
                        self.arrayComponents.remove(at: indexPath.row)
                        
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            
            case .excursionPaymentMethod:
                self.excursionsModel.deleteAutofill(token: self.user?.getToken() ?? "", companyId: self.user?.company.getLocalIDCompany() ?? "", autofillKey: .excursionPaymentMethod, autofillValue: arrayComponents[indexPath.row]) { isDeleted, error in
                    
                    if let err = error{
                        self.alerts.errorAlert(self, errorAutoFillApi: err)
                    }
                    
                    if isDeleted{
                        self.arrayComponents.remove(at: indexPath.row)
                        
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
                
            case .guides:
                break
            }
        }
        
        if arrayComponents.isEmpty{
            self.navigationItem.rightBarButtonItem!.title = "Edit"
            self.tableView.setEditing(false, animated: true)
        }
    }
    @objc func toggleEditMode(){
        if typeOfNewComponent == .guides{
            return
        }
        
        self.tableView.isEditing ? self.tableView.setEditing(false, animated: true) : self.tableView.setEditing(true, animated: true)
        
        
    }
    
}


// MARK: - UIGestureRecognizerDelegate
extension AddingNewComponentViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
