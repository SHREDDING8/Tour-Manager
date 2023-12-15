//
//  EmploeeTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit
import AlertKit
import SnapKit

class EmploeeTableViewController: BaseViewController{
    
    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.register(OneEmployeeTableViewCell.self, forCellReuseIdentifier: "employee")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { _ in
            DispatchQueue.main.async {
                self.presenter.getUsersFromServer()
            }
        }))
        
        return tableView
    }()
    
    var presenter:EmployeesListPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.view.backgroundColor = UIColor(resource: .background)
        
        self.titleString = "Сотрудники"
        self.setBackButton()
        
        presenter.getUsersFromRealm()
        
        DispatchQueue.main.async {
            self.presenter.getUsersFromServer()
        }
        
    }
    
}
// MARK: - Table view data source
extension EmploeeTableViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.users.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employee", for: indexPath) as! OneEmployeeTableViewCell
        let employee = presenter.users[indexPath.row]
        cell.name.text = employee.fullName
        
        if let image = employee.images.first{
            cell.image.image = image.image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destination = EmployeeAseembly.EmployeeDetailController(user: presenter.users[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension EmploeeTableViewController:EmployeesListViewProtocol{
    
    func endRefreshing(){
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func updateUsersList() {
        self.tableView.reloadSections([0], with: .automatic)
       
    }
    
}
