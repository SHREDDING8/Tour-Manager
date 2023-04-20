//
//  ViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.04.2023.
//

import UIKit

class LogInViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var welcomeOutlet: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogInButton()
        configureLineUnderTextFields()
    }
    // MARK: - Configuration
    
    fileprivate func configureLogInButton(){
        self.logInButton.clipsToBounds = true
        self.logInButton.layer.masksToBounds = true
        self.logInButton.layer.cornerRadius = self.logInButton.frame.height / 2
    }
    fileprivate func configureLineUnderTextFields(){
        for i in 1...2{
            self.view.viewWithTag(i)!.clipsToBounds = true
            self.view.viewWithTag(i)!.layer.masksToBounds = true
            self.view.viewWithTag(i)!.layer.cornerRadius = 2
        }
    }
}

