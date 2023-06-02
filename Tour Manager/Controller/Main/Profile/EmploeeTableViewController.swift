//
//  EmploeeTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit

class EmploeeTableViewController: UITableViewController {
    
    let controllers = Controllers()
    
    var emploee:[User] = []
    
    let user = AppDelegate.user
    
    let refreshControll = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEmpoloee()

        self.navigationItem.title = "Работники"
        
        let refresh = UIAction { _ in
            self.getEmpoloee()
        }
        
        refreshControll.addAction(refresh, for: .valueChanged)
        tableView.refreshControl = refreshControll
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return emploee.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emploeeCell", for: indexPath)

        // Configure the cell...

        return cell
    }
    
    
    public func getEmpoloee(){
        self.user?.company.getCompanyUsers(token: self.user?.getToken() ?? "", completion: { isGetted, employee, error in
            if isGetted{
                self.emploee = employee ?? []
                self.tableView.reloadData()
                self.refreshControll.endRefreshing()
            }
        })
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.goToEmployeeViewController(employee: self.emploee[indexPath.row])
    }





    // MARK: - Navigation
    fileprivate func goToEmployeeViewController(employee:User){
        
        let destination = controllers.getControllerMain(.employeeViewController) as! EmploeeViewController
        destination.employee = employee
        self.navigationController?.pushViewController(destination, animated: true)
    }


}
