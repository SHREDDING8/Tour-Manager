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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = EmployeesListPresenter(view: self)
        presenter.getUsersFromRealm()
        
        DispatchQueue.main.async {
            self.presenter.getUsersFromServer()
        }
        
        self.navigationItem.title = "Работники"
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "emploeeCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
        label.text = presenter.users[indexPath.row].fullName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destination = EmployeeAseembly.EmployeeDetailController(user: presenter.users[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
        
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
