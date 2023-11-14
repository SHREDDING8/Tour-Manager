//
//  ProfileViewElement.swift
//  Tour Manager
//
//  Created by SHREDDING on 11.11.2023.
//

import UIKit
import SnapKit

class ProfileViewElement: UIView {
    
    lazy var elementLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .blueText)
        return label
    }()
    
    lazy var textField:UITextField = {
        let view = UITextField()
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return view
    }()
    
    lazy var button:UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(resource: .blueText)
        
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        self.addSubview(elementLabel)
        self.addSubview(textField)
        self.addSubview(button)
        
        elementLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(elementLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(textField.snp.trailing).offset(5)
            make.centerY.equalTo(textField.snp.centerY)
            make.width.equalTo(textField.snp.height)
        }
    }
}
