//
//  ChoiceOfTypeAccountViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import UIKit

class ChoiceOfTypeAccountViewController: UIViewController {
    
    // MARK: - my Variables
    let controllers = Controllers()
    
    var registerData:[String:String] = [
        "email": "",
        "password" : ""
    ]
    
    // MARK: - Outlets

    @IBOutlet weak var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    


    // MARK: - Navigation
     
    @IBAction func tapEmployeeButton(_ sender: Any) {
        nextController(nextController: .emploee)
    }
    
    @IBAction func tapNewCompanyButton(_ sender: Any) {
        nextController(nextController: .company)
    }
    
    
    func nextController(nextController:TypeOfRegister) {
        
        let destination = controllers.getControllerAuth(.addingPersonalInformation) as! AddingPersonalDataViewController
        
        destination.registerData = self.registerData
        destination.typeOfRegister = nextController
        
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destination, animated: true)
        }
        
    }
    
}
