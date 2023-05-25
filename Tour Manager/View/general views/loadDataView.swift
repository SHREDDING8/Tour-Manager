//
//  loadDataView.swift
//  Tour Manager
//
//  Created by SHREDDING on 23.05.2023.
//

import Foundation
import UIKit

class generalViews{
    public static var loadDataView:UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .black
        uiView.layer.opacity = 0
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        uiView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: uiView.centerYAnchor)
        ])
        
        return uiView
    }()
}


