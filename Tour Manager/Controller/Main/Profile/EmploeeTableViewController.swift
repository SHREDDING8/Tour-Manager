//
//  EmploeeTableViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 01.06.2023.
//

import UIKit

class EmploeeTableViewController: UITableViewController {
    
    let controllers = Controllers()
    let alerts = Alert()
    
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emploee.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emploeeCell", for: indexPath)
        
        let label = cell.viewWithTag(2) as! UILabel
        label.text = emploee[indexPath.row].getFullName()
        
        return cell
    }
    
    
    public func getEmpoloee(){
        self.user?.company.getCompanyUsers(token: self.user?.getToken() ?? "", completion: { isGetted, employee, error in
            
            if let err = error{
                self.alerts.errorAlert(self, errorCompanyApi: err)
            }
            
            if isGetted{
                self.emploee = employee ?? []
                
                
                UIView.transition(with: self.tableView, duration: 0.3,options: .transitionCrossDissolve) {
                    self.tableView.reloadData()
                }
                
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
