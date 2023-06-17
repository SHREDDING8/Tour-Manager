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
    
    case guides
    
}

class AddingNewComponentViewController: UIViewController {
    
    // MARK: - My variables
    
    var excursion:Excursion!
    
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
    
    
    // MARK: - configuration
    
    fileprivate func configureView(){
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))
        
        self.textField.addTarget(self, action: #selector(getNewHint), for: .editingChanged)
        
        
        switch typeOfNewComponent{
            
        case .route:
            self.title = "Маршрут"
            textField.placeholder = "Маршрут"
            textField.text = excursion.route
            self.arrayComponents = self.excursion.routes
            self.fullArrayComponents = self.arrayComponents
        case .customerCompanyName:
            self.title = "Название компании"
            textField.placeholder = "Название компании"
            textField.text = excursion.customerCompanyName
            self.arrayComponents = self.excursion.customerCompanyNames
            self.fullArrayComponents = self.arrayComponents
        case .customerGuiedName:
            self.title = "ФИО сопровождающего"
            textField.placeholder = "ФИО сопровождающего"
            textField.text = excursion.customerGuideName
            self.arrayComponents = self.excursion.customerGuideNames
            self.fullArrayComponents = self.arrayComponents
        case .guides:
            self.title = "Экскурсоводы"
            textField.placeholder = "Экскурсовод"
            
            self.user?.company.getCompanyGuides(token: self.user?.getToken() ?? "", completion: { isGetted, guides, error in
                if isGetted{
                    for guide in guides!{
                        let newGuide = SelfGuide(guideInfo: guide, isMain: false)
                        self.arrayWithGuides.append(newGuide)
                    }
                    self.fullArrayWithGuides = self.arrayWithGuides
                    self.tableView.reloadData()
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.textField.text = (tableView.cellForRow(at: indexPath) as! NewComponentTableViewCell).componentText.text
        
        self.textFieldDidEndEditing(self.textField)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if tableView.isEditing{
            self.navigationItem.rightBarButtonItem!.title = "Done"
        }else{
            self.navigationItem.rightBarButtonItem!.title = "Edit"
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            arrayComponents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        if arrayComponents.isEmpty{
            self.navigationItem.rightBarButtonItem!.title = "Edit"
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    @objc func toggleEditMode(){
        
        self.tableView.isEditing ? self.tableView.setEditing(false, animated: true) : self.tableView.setEditing(true, animated: true)
        
    }
}
