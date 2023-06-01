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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEmpoloee()

        self.navigationItem.title = "Работники"
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
        for _ in 0...10{
            let emploee = User(token: "", localId: "", email: "example@mail.com", firstName: "Egor", secondName: "Zavrazhnov", birthday: Date.now, phone: "89047813590")
            self.emploee.append(emploee)
        }
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
