//
//  EmploeeTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit
import AlertKit

class EmploeeTableViewController: UITableViewController {
    
    var presenter:EmployeesListPresenterProtocol!
    
    let controllers = Controllers()
    let alerts = Alert()
            
    let refreshControll = UIRefreshControl()
    
    var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(OneEmployeeTableViewCell.self, forCellReuseIdentifier: "employee")
        
        presenter.getUsersFromRealm()
        
        DispatchQueue.main.async {
            self.presenter.getUsersFromServer()
        }
        
        self.navigationItem.title = "Сотрудники"
        
        let refresh = UIAction { _ in
            DispatchQueue.main.async {
                self.presenter.getUsersFromServer()
            }
        }
        
        refreshControll.addAction(refresh, for: .valueChanged)
        tableView.refreshControl = refreshControll
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employee", for: indexPath) as! OneEmployeeTableViewCell
        let employee = presenter.users[indexPath.row]
        cell.name.text = employee.fullName
        
        if let image = employee.images.first{
            cell.image.image = image.image
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destination = EmployeeAseembly.EmployeeDetailController(user: presenter.users[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

}

extension EmploeeTableViewController:EmployeesListViewProtocol{
    
    func updateUsersList() {
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func unknownError(){
        AlertKitAPI.present(title: "Нeизвестная ошибка", icon: .error, style: .iOS17AppleMusic, haptic: .error)
    }
    
}
