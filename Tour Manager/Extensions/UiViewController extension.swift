//
//  UiViewController extension.swift
//  Tour Manager
//
//  Created by SHREDDING on 14.10.2023.
//

import Foundation

import UIKit
import SwiftUI

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController (context: Context) -> some UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
    func showPreview() -> some View {
        Preview (viewController:self).ignoresSafeArea()
    }
}


import UIKit
import SwiftUI

extension UIView {
    private struct Preview: UIViewRepresentable {

        typealias UIViewType = UIView
        let view: UIView
        
        func makeUIView(context: Context) -> UIView {
            view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            //
        }
    }
    func showPreview() -> some View {
        Preview(view: self)
    }
}

