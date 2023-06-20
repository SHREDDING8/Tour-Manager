//
//  datepickerFromBottom.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.06.2023.
//

import Foundation
import UIKit

class DatepickerFromBottom{
    private let viewController:UIViewController
    
    var datePickerHeightConstraint:NSLayoutConstraint!
    
    let pickerView:UIView = {
        
        let buttonFont = Font.getFont(name: .americanTypewriter, style: .bold, size: 16)
        
        let pickerView = UIView()
        pickerView.backgroundColor = .white
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        picker.minimumDate = Date.birthdayFromString(dateString: "01.01.1900")
        picker.maximumDate = Date.now
        
        pickerView.addSubview(picker)
        
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = buttonFont
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        pickerView.addSubview(doneButton)
        
        let cancelButton = UIButton(type: .system)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = buttonFont
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        pickerView.addSubview(cancelButton)
        
        let line = UIView()
        line.backgroundColor = .gray
        line.translatesAutoresizingMaskIntoConstraints = false
        
        pickerView.addSubview(line)
        
        return pickerView
        
    }()
    
    let darkUIView:UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.opacity = 0
        view.translatesAutoresizingMaskIntoConstraints = false
                
        return view
        
    }()
    
    init(viewController: UIViewController, doneAction: @escaping (Date)->Void) {
        self.viewController = viewController
        self.viewController.view.addSubview(self.darkUIView)
        self.viewController.view.addSubview(self.pickerView)
        
        
        let picker = self.pickerView.subviews[0] as! UIDatePicker
        let doneButton = self.pickerView.subviews[1] as! UIButton
        
        doneButton.addAction(UIAction(handler: { _ in
            doneAction(picker.date)
        }), for: .touchUpInside)
        
        
        self.setConstaints()
    }
    
    private func setConstaints(){
        
        
        let picker = self.pickerView.subviews[0] as! UIDatePicker
        
        let doneButton = self.pickerView.subviews[1] as! UIButton
        
        let cancelButton = self.pickerView.subviews[2] as! UIButton
        
        let line = self.pickerView.subviews[3]
        
        doneButton.addAction(UIAction(handler: { _ in
            UIView.transition(with: self.pickerView, duration: 0.5) {
                self.datePickerHeightConstraint.constant = 0
                self.viewController.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.viewController.tabBarController?.tabBar.layer.opacity = 1
                self.darkUIView.layer.opacity = 0
            }
        }), for: .touchUpInside)
        
        cancelButton.addAction(UIAction(handler: { _ in
            UIView.transition(with: self.pickerView, duration: 0.5) {
                self.datePickerHeightConstraint.constant = 0
                self.viewController.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.viewController.tabBarController?.tabBar.layer.opacity = 1
                self.darkUIView.layer.opacity = 0
            }
        }), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            self.darkUIView.topAnchor.constraint(equalTo: self.viewController.view.topAnchor),
            self.darkUIView.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor),
            self.darkUIView.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor),
            self.darkUIView.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor)
        ])
        
        
        datePickerHeightConstraint = NSLayoutConstraint(item: self.pickerView , attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        self.pickerView.addConstraint(datePickerHeightConstraint)
        
        NSLayoutConstraint.activate([
            self.pickerView.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor, constant: 0),
            self.pickerView.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor),
            self.pickerView.trailingAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            picker.trailingAnchor.constraint(equalTo: self.pickerView.trailingAnchor),
            picker.leadingAnchor.constraint(equalTo: self.pickerView.leadingAnchor),
            picker.bottomAnchor.constraint(equalTo: self.pickerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: self.pickerView.topAnchor, constant: 5),
            doneButton.trailingAnchor.constraint(equalTo: self.pickerView.trailingAnchor, constant: -10),
            doneButton.bottomAnchor.constraint(equalTo: picker.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: self.pickerView.topAnchor, constant: 5),
            cancelButton.leadingAnchor.constraint(equalTo: self.pickerView.leadingAnchor, constant: 10),
            cancelButton.bottomAnchor.constraint(equalTo: picker.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor),
            line.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 0),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    public func setDatePicker(){
        UIView.transition(with: self.pickerView, duration: 0.5) {
            self.datePickerHeightConstraint.constant = self.viewController.view.frame.height / 2
            self.viewController.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.viewController.tabBarController?.tabBar.layer.opacity = 0
            self.darkUIView.layer.opacity = 0.5
        }
    }
}
