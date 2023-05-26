//
//  ForgotPasswordViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 21.04.2023.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogInButton()
        configureLineUnderTextFields()
    }
    
    // MARK: - Configuration
    
    fileprivate func configureLogInButton(){
        self.signInButton.clipsToBounds = true
        self.signInButton.layer.masksToBounds = true
        self.signInButton.layer.cornerRadius = self.signInButton.frame.height / 2
    }
    fileprivate func configureLineUnderTextFields(){
        for i in 1...2{
            self.view.viewWithTag(i)!.clipsToBounds = true
            self.view.viewWithTag(i)!.layer.masksToBounds = true
            self.view.viewWithTag(i)!.layer.cornerRadius = 2
        }
        
    }
    


}
