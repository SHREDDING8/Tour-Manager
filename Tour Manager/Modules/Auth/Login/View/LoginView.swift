//
//  LoginView.swift
//  Tour Manager
//
//  Created by SHREDDING on 13.12.2023.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    lazy var greeting:UILabel = {
        let label = UILabel()
        label.text = "Добро пожаловать!"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(resource: .blueText)
        
        return label
    }()
    
    lazy var logo:UIImageView = {
        let view = UIImageView(image: UIImage(resource: .iconImg))
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var textFieldsStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.spacing = 10
        return stack
    }()
    
    lazy var email:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Email"
        view.textField.placeholder = "Введите email"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = false
        
        view.textField.keyboardType = .emailAddress
        view.textField.autocapitalizationType = .none
        
        view.textField.restorationIdentifier = "email"
        
        return view
    }()
    
    lazy var password:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Пароль"
        view.textField.placeholder = "Введите пароль"
        view.textField.isSecureTextEntry = true
        view.textField.clearsOnBeginEditing = true
        
        view.textField.restorationIdentifier = "password"
        
        return view
    }()
    
    lazy var confirmPassword:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Повторите пароль"
        view.textField.placeholder = "Повторите пароль"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = true
        
        view.textField.restorationIdentifier = "secondNewPassword"
        
        view.isHidden = true
        
        return view
    }()
    
    lazy var logInButton:UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.baseBackgroundColor = .init(resource: .blueText)
        conf.baseForegroundColor = .white
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Войти", size: 16, style: .regular)
        
        return button
    }()
    
    lazy var helpButtonsStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        
        return stack
    }()
    
    lazy var changeModeButton:UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.baseBackgroundColor = .clear
        conf.baseForegroundColor = .init(resource: .blueText)
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Регистрация", size: 12, style: .regular)
        return button
    }()
    
    lazy var forgotPassword:UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.baseBackgroundColor = .clear
        conf.baseForegroundColor = .init(resource: .blueText)
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Забыли пароль?", size: 12, style: .regular)
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
        self.addSubview(greeting)
        self.addSubview(logo)
        self.addSubview(textFieldsStack)
        self.textFieldsStack.addArrangedSubview(email)
        self.textFieldsStack.addArrangedSubview(password)
        self.textFieldsStack.addArrangedSubview(confirmPassword)
        
        self.addSubview(logInButton)
        self.addSubview(helpButtonsStack)
        
        self.helpButtonsStack.addArrangedSubview(changeModeButton)
        self.helpButtonsStack.addArrangedSubview(forgotPassword)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        greeting.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        
        logo.snp.makeConstraints { make in
            make.top.equalTo(greeting.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        textFieldsStack.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        logInButton.snp.makeConstraints { make in
            make.bottom.equalTo(helpButtonsStack.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        helpButtonsStack.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

}

import SwiftUI
#Preview(body: {
    LoginView().showPreview()
})
