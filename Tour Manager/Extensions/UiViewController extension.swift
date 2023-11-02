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

//extension UIView {
//    // enable preview for UIKit
//    // source: https://dev.to/gualtierofr/preview-uikit-views-in-xcode-3543
//    @available(iOS 13, *)
//    private struct Preview: UIViewRepresentable {
//        typealias UIViewType = UIView
//        let view: UIView
//        func makeUIView(context: Context) -> UIView {
//            return view
//        }
//        
//        func updateUIView(_ uiView: UIView, context: Context) {
//            //
//        }
//    }
//    
//    @available(iOS 13, *)
//    func showPreview() -> some View {
//        // inject self (the current UIView) for the preview
//        Preview(view: self)
//    }
//}

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

