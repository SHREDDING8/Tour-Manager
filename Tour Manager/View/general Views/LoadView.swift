//
//  LoadView.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.06.2023.
//

import Foundation
import UIKit

class LoadView{
    
    // MARK: - Views
    private let viewController:UIViewController
    
    private let loadUIView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.opacity = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = 1
        view.addSubview(activityIndicator)
        
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return view
        
    }()
    
    // MARK: - Init
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        self.viewController.view.addSubview(loadUIView)
        
        self.constaintLoadUIView()
    }
    
    // MARK: - Configuration
    
    private func constaintLoadUIView(){
        NSLayoutConstraint.activate([
            self.loadUIView.leadingAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.leadingAnchor),
            self.loadUIView.trailingAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.trailingAnchor),
            self.loadUIView.topAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.topAnchor),
            self.loadUIView.bottomAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Action
    
    public func setLoadUIView(){
        let activityIndicator = self.loadUIView.viewWithTag(1) as! UIActivityIndicatorView
        activityIndicator.startAnimating()
        
        UIView.animate(withDuration: 0.3) {
            self.loadUIView.layer.opacity = 0.5
        }
    }
    
    public func removeLoadUIView(){
        let activityIndicator = self.loadUIView.viewWithTag(1) as! UIActivityIndicatorView
        
        UIView.animate(withDuration: 0.3) {
            self.loadUIView.layer.opacity = 0
        }
        activityIndicator.stopAnimating()
    }
    
}
