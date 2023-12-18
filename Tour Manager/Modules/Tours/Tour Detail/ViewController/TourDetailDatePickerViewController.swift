//
//  TourDetailDatePickerViewController.swift
//  Tour Manager
//
//  Created by SHREDDING on 18.12.2023.
//

import UIKit
import SnapKit


class TourDetailDatePickerViewController: UIViewController {
    
    var doAfterChange:((Date)->Void)?
    
    lazy var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        
        return datePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(resource: .background)
        self.view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        datePicker.addAction(UIAction(handler: { _ in
            self.doAfterChange?(self.datePicker.date)
        }), for: .valueChanged)
    }
    
}
