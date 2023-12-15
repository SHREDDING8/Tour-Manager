//
//  AddingNewComponentViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 13.06.2023.
//

import UIKit


class AddingNewComponentViewController: BaseViewController {
    
    var presenter:AddingNewComponentPresenterProtocol!
    
    var doAfterClose: ((String)->Void)?
        
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
        line.backgroundColor = UIColor(named: "blueText")
        line.layer.cornerRadius = 5
        line.layer.opacity = 0.5
        return line
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(resource: .background)
        
        self.setBackButton()
        
        configureView()
        addSubviews()
        configureTextFieldAndLine()
        configureTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.willAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.willDissapear()
        
        self.textField.resignFirstResponder()
        doAfterClose?(presenter.selectedValue)
        
    }
    
    
    // MARK: - configuration
    
//    fileprivate func getHintsFromApi() {
//        self.arrayComponents = []
//        self.arrayWithGuides = []
//        
//        switch typeOfNewComponent{
//        case .route:
//            self.title = "Маршрут"
//            textField.placeholder = "Маршрут"
//            textField.text = excursion.route
//            
//            presenter.getAutofill(autofillKey: .excursionRoute) { isGetted, values, error in
//                if let err = error{
//                    self.alerts.errorAlert(self, errorAutoFillApi: err)
//                }
//                if isGetted{
//                    self.arrayComponents = values!
//                    self.fullArrayComponents = self.arrayComponents
//                    self.tableView.reloadData()
//                }
//            }
//        case .customerCompanyName:
//            self.title = "Название компании"
//            textField.placeholder = "Название компании"
//            textField.text = excursion.customerCompanyName
//            presenter.getAutofill(autofillKey: .excursionCustomerCompanyName) { isGetted, values, error in
//                if let err = error{
//                    self.alerts.errorAlert(self, errorAutoFillApi: err)
//                }
//                if isGetted{
//                    self.arrayComponents = values!
//                    self.fullArrayComponents = self.arrayComponents
//                    self.tableView.reloadData()
//                }
//            }
//        case .customerGuiedName:
//            self.title = "ФИО сопровождающего"
//            textField.placeholder = "ФИО сопровождающего"
//            textField.text = excursion.customerGuideName
//            presenter.getAutofill(autofillKey: .excursionCustomerGuideContact) { isGetted, values, error in
//                if let err = error{
//                    self.alerts.errorAlert(self, errorAutoFillApi: err)
//                }
//                if isGetted{
//                    self.arrayComponents = values!
//                    self.fullArrayComponents = self.arrayComponents
//                    self.tableView.reloadData()
//                }
//            }
//            
//        case .excursionPaymentMethod:
//            self.title = "Способ оплаты"
//            textField.placeholder = "Способ оплаты"
//            textField.text = excursion.paymentMethod
//            
//            presenter.getAutofill(autofillKey: .excursionPaymentMethod) { isGetted, values, error in
//                if let err = error{
//                    self.alerts.errorAlert(self, errorAutoFillApi: err)
//                }
//                if isGetted{
//                    self.arrayComponents = values!
//                    self.fullArrayComponents = self.arrayComponents
//                    self.tableView.reloadData()
//                }
//            }
//            
//            
//        case .guides:
//            self.title = "Экскурсоводы"
//            textField.placeholder = "Найти"
//            
//            presenter.getCompanyGuides(completion: { isGetted, guides, error in
//                
//                if let err = error{
//                    self.alerts.errorAlert(self, errorCompanyApi: err)
//                }
//                
//                if isGetted{
//                    for guide in guides!{
//                        let newGuide = SelfGuide(guideInfo: guide, isMain: false)
//                        self.arrayWithGuides.append(newGuide)
//                    }
//                    self.fullArrayWithGuides = self.arrayWithGuides
//                    self.tableView.reloadData()
//                    
//                    if self.fullArrayWithGuides.count > 0{
//                        self.showContextualAction(cell: self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NewComponentTableViewCell)
//                    }
//                    
//                }
//            })
//        }
//    }
    
    fileprivate func configureView(){
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate? = self
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(toggleEditMode))
                        
        self.textField.addTarget(self, action: #selector(getNewHint), for: .editingChanged)
        
//        self.getHintsFromApi()
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
    
    @objc func getNewHint(){
        
        presenter.textFieldChanged(text: self.textField.text ?? "")
        
    }
}


// MARK: - Table View
extension AddingNewComponentViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.presentedValues.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewComponentTableViewCell") as! NewComponentTableViewCell
        
        cell.componentText.text = presenter.presentedValues[indexPath.row].value 
        
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
        textField.resignFirstResponder()
        presenter.didSelect(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
                
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
        if editingStyle == .delete{
            presenter.deleteAt(index: indexPath.row)
        }
        
        if presenter.presentedValues.count == 0{
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    @objc func toggleEditMode(){

        self.tableView.isEditing ? self.tableView.setEditing(false, animated: true) : self.tableView.setEditing(true, animated: true)
    }
    
}


// MARK: - UIGestureRecognizerDelegate
//extension AddingNewComponentViewController:UIGestureRecognizerDelegate{
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

extension AddingNewComponentViewController:AddingNewComponentViewProtocol{
    
    func configureRouteView() {
        let valueString = "Маршрут"
        self.titleString = valueString
        textField.placeholder = valueString
    }
    
    func configureCustomerCompanyNameView() {
        let valueString = "Название компании"
        self.titleString = valueString
        textField.placeholder = valueString
    }
    
    func configureCustomerGuiedNameView() {
        let valueString = "Сопровождающий"
        self.titleString = valueString
        textField.placeholder = valueString
    }
    
    func configureExcursionPaymentMethodView() {
        let valueString = "Способ оплаты"
        self.titleString = valueString
        textField.placeholder = valueString
    }
    
    func updateTableView() {
        self.tableView.reloadData()
    }
    
    func setTextField(text: String) {
        self.textField.text = text
    }
    
    func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
