//
//  ViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.04.2023.
//

import UIKit

class LogIn: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var welcomeOutlet: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var underEmailUiview: UIView!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var forgotPasswordButton: UILabel!
    
    @IBOutlet weak var createNewAccountButton: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogInButton()
    }
    // MARK: - Configuration
    
    fileprivate func configureLogInButton(){
        self.logInButton.clipsToBounds = true
        self.logInButton.layer.masksToBounds = true
        self.logInButton.layer.cornerRadius = self.logInButton.frame.height / 2
    }
}

