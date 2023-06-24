//
//  UITableViewControllerContainer.swift
//  Tour Manager
//
//  Created by SHREDDING on 22.06.2023.
//

import UIKit

class UITableViewControllerContainer: UIViewController {
    
    let controllers = Controllers()
    
    
    let acceptUIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        
//        let path = UIBezierPath(roundedRect:view.bounds,
//                                byRoundingCorners:[.topRight, .topLeft],
//                                cornerRadii: CGSize(width: 20, height:  20))
//        let maskLayer = CAShapeLayer()
//
//        maskLayer.path = path.cgPath
//        view.layer.mask = maskLayer
        
        let label = UILabel()
        label.text = "123123"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.leftAnchor.constraint(equalTo: view.leftAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        return view
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tourForGuide = controllers.getControllerMain(.excursionForGuideTableViewController)
        
        self.addChild(tourForGuide)
        self.view.addSubview(tourForGuide.view)
        
        configureView()
    
    }
    
    fileprivate func configureView(){
        self.view.addSubview(self.acceptUIView)
        self.view.bringSubviewToFront(self.acceptUIView)
        NSLayoutConstraint.activate([
            self.acceptUIView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.acceptUIView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.acceptUIView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.acceptUIView.heightAnchor.constraint(equalToConstant: (self.view.frame.height) / 4)
        ])
    }


}
