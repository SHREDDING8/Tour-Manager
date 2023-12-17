//
//  AddGuideViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 22.10.2023.
//

import UIKit
import SnapKit

final class AddGuideViewController: BaseViewController {
    
    var presenter:AddGuidePresenterProtocol!
    var doAfterClose:(([ExcrusionModel.Guide])->Void)?
        
    lazy var searchcontroller:UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Найти экскурсовода"
        
        return controller
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        tableView.register(OneEmployeeTableViewCell.self, forCellReuseIdentifier: "employee")
        
        let refresh = UIRefreshControl(frame: CGRect.zero, primaryAction: UIAction(handler: { _ in
            self.presenter.getUsersFromServer()
        }))
        
        tableView.refreshControl = refresh
        
        return tableView
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
        self.navigationItem.searchController = searchcontroller
        
        self.view.addSubview(self.tableView)
               
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.trailing.leading.bottom.equalToSuperview()
        }
        
    }
    

}

extension AddGuideViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        presenter.textFieldChanged(text: searchController.searchBar.text ?? "")
    }
    
    
}

extension AddGuideViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "employee") as! OneEmployeeTableViewCell
        
        cell.accessoryType = .none
        
        if indexPath.section == 0{
            
            let guide = self.presenter.selectedGuides[indexPath.row]
            
            cell.name.text = "\(guide.isMain == true ? "★" : "") \(guide.firstName) \(guide.lastName)"
            
            if let image = guide.images.first{
                cell.image.image = image.image
            }
            
            return cell
            
        } else {
            
            
            let guide = presenter.getPresentGuide(index: indexPath.row)
            
            cell.name.text = guide.fullName
            
            
            if let image = guide.images.first{
                cell.image.image = image.image
            }
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
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
    func endRefreshing() {
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func updateUsersList() {
        tableView.reloadSections([0,1], with: .automatic)
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
