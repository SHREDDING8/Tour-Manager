//
//  NoConnectionViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 02.07.2023.
//

import UIKit

class NoConnectionViewController: UIViewController {

    @IBOutlet weak var activityController: UIActivityIndicatorView!{
        didSet{
            self.activityController.startAnimating()
        }
    }
    
    let generalData = GeneralData()
    
    let controllers = Controllers()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 11, repeats: true) { timer in
            self.generalData.checServerkConnection { isConnected in
                if isConnected{
                    timer.invalidate()
                    self.controllers.goToLauchScreen(view: self.view, direction: .fade)
                }
            }
        }
    }
}
