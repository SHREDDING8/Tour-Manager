//
//  AddGuideViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 22.10.2023.
//

import UIKit
import SnapKit

class AddGuideViewController: BaseViewController {
    
    var presenter:AddGuidePresenterProtocol!
    var doAfterClose:(([ExcrusionModel.Guide])->Void)?
    
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Font.getFont(name: .americanTypewriter, style: .bold, size: 24)
        textField.delegate = self
        
        textField.placeholder = "Поиск"
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        let refresh = UIRefreshControl(frame: CGRect.zero, primaryAction: UIAction(handler: { _ in
            self.presenter.getUsersFromServer()
        }))
        
        tableView.refreshControl = refresh
        
        return tableView
    }()
    
    lazy var line:UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(resource: .blueText)
        line.layer.cornerRadius = 5
        line.layer.opacity = 0.5
        return line
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadGuides()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doAfterClose?(presenter.selectedGuides)
    }
    
    
    func configureView(){
        self.view.backgroundColor = UIColor(resource: .background)
        self.titleString = "Экскурсоводы"
        self.setBackButton()
        
        self.view.addSubview(self.textField)
        self.view.addSubview(self.line)
        self.view.addSubview(self.tableView)
        
        let nibcell = UINib(nibName: "NewComponentTableViewCell", bundle: nil)
        tableView.register(nibcell, forCellReuseIdentifier: "NewComponentTableViewCell")
       
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        line.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(10)
            make.top.equalTo(textField.snp.bottom).offset(2)
            make.height.equalTo(2)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(30)
            make.trailing.leading.bottom.equalToSuperview()
        }
        
    }
    

}

extension AddGuideViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc func textFieldChanged(){
        presenter.textFieldChanged(text: self.textField.text ?? "")
    }
    
}

extension AddGuideViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "Выбранные"
        }else{
            return "Все"
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.presenter.selectedGuides.count
        }
        return self.presenter.filterPresentedGuides().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewComponentTableViewCell") as! NewComponentTableViewCell
            let guide = self.presenter.selectedGuides[indexPath.row]
            
            cell.componentText.text = "\(guide.firstName) \(guide.lastName)"
            cell.accessoryType = .checkmark
            
            if guide.isMain{
                cell.componentText.text! += " ★"
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewComponentTableViewCell") as! NewComponentTableViewCell
            
            let guide = presenter.getPresentGuide(index: indexPath.row)
            
            cell.componentText.text = guide.fullName
            
            cell.accessoryType = .none
            
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            presenter.didSelectSelected(index: indexPath.row)
        }else{
            presenter.didSelectPresented(index: indexPath.row)
        }
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 || self.presenter.isMain(index: indexPath.row){
            return nil
        }
        
        let mainGuideAction = UIContextualAction(style: .normal, title: nil) {  (contextualAction, view, boolValue) in
            self.presenter.setMain(index: indexPath.row)
            
            boolValue(true)
            
        }
        
        mainGuideAction.image = UIImage(systemName: "star.fill")
        mainGuideAction.backgroundColor = .systemGreen
        
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [mainGuideAction])
        
        return swipeConfiguration
    }
    
}

extension AddGuideViewController:AddGuideViewProtocol{
    func updateUsersList() {
        tableView.reloadSections([0,1], with: .automatic)
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func updateAllGuidesList(){
        tableView.reloadSections([1], with: .automatic)
        self.tableView.refreshControl?.endRefreshing()
    }
    
}

#if DEBUG
import SwiftUI

#Preview(body: {
    AddGuideViewController().showPreview()
})
#endif
