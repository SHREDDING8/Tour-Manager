//
//  ChangePasswordView.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.12.2023.
//

import UIKit
import SnapKit

final class ChangePasswordView: UIView {
    
    private lazy var logo:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(resource: .iconImg)
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var passwordsStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        
        return stack
    }()
    
    lazy var oldPassword:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Старый пароль"
        view.textField.placeholder = "Старый пароль"
        view.textField.isSecureTextEntry = true
        view.textField.clearsOnBeginEditing = true
        
        view.textField.restorationIdentifier = "oldPassword"
        
        return view
    }()
    
    lazy var newPassword:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Новый пароль"
        view.textField.placeholder = "Новый пароль"
        view.textField.isSecureTextEntry = true
        view.textField.clearsOnBeginEditing = true
        
        view.textField.restorationIdentifier = "newPassword"
        
        return view
    }()
    
    lazy var confirmPassword:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Повторите пароль"
        view.textField.placeholder = "Повторите пароль"
        view.textField.isSecureTextEntry = true
        view.textField.clearsOnBeginEditing = true
        
        view.textField.restorationIdentifier = "secondNewPassword"
        
        return view
    }()
    
    lazy var changeButtonPassword:UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.baseBackgroundColor = .init(resource: .blueText)
        conf.baseForegroundColor = .white
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Изменить пароль", size: 16, style: .regular)
        
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
        self.backgroundColor = UIColor(resource: .background)
        
        self.addSubview(logo)
        self.addSubview(passwordsStack)
        
        self.passwordsStack.addArrangedSubview(oldPassword)
        self.passwordsStack.addArrangedSubview(newPassword)
        self.passwordsStack.addArrangedSubview(confirmPassword)
        
        self.addSubview(changeButtonPassword)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logo.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        passwordsStack.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            
        }
        
        changeButtonPassword.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

import SwiftUI
#Preview(body: {
    ChangePasswordView().showPreview()
})
