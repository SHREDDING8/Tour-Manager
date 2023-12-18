//
//  SetInfoView.swift
//  Tour Manager
//
//  Created by SHREDDING on 15.12.2023.
//

import UIKit
import SnapKit

final class SetInfoView: UIView {
    
    lazy var scrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        
        return scroll
    }()
    
    lazy var scrollContent:UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var logo:UIImageView = {
        let view = UIImageView(image: UIImage(resource: .iconImg))
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var itemsStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        
        return stack
    }()
    
    lazy var company:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Название организации"
        view.textField.placeholder = "Введите название"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = false
                
        view.textField.restorationIdentifier = "company"
        
        return view
    }()
    
    lazy var name:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Имя"
        view.textField.placeholder = "Введите имя"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = false
                
        view.textField.restorationIdentifier = "name"
        
        return view
    }()
    
    lazy var secondName:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Фамилия"
        view.textField.placeholder = "Введите фамилию"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = false
                
        view.textField.restorationIdentifier = "secondName"
        
        return view
    }()
    
    lazy var birthday:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Дата рождения"
        view.textField.placeholder = "Введите дату рождения"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = false
        
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        view.textField.inputView = datePicker
        view.textField.addDoneCancelToolbar()
        
        datePicker.addAction(UIAction(handler: { _ in
            view.textField.text = datePicker.date.birthdayToString()
        }), for: .valueChanged)
        
        view.button.addAction(UIAction(handler: { _ in
            view.textField.isUserInteractionEnabled = true
            view.textField.becomeFirstResponder()
        }), for: .touchUpInside)
        
        view.textField.text = Date.now.birthdayToString()
                
        view.textField.restorationIdentifier = "birthday"
        
        return view
    }()
    
    lazy var phone:ProfileViewElement = {
        let view = ProfileViewElement()
        view.button.isHidden = true
        view.elementLabel.text = "Телефон"
        view.textField.placeholder = "Введите телефон"
        view.textField.isSecureTextEntry = false
        view.textField.clearsOnBeginEditing = false
        
        view.textField.keyboardType = .phonePad
        view.textField.addDoneCancelToolbar()
                
        view.textField.restorationIdentifier = "phone"
        
        return view
    }()
    
    lazy var continueButton:UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.baseBackgroundColor = .init(resource: .blueText)
        conf.baseForegroundColor = .white
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Продолжить", size: 16, style: .regular)
        
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
        
        self.addSubview(scrollView)
        self.scrollView.addSubview(scrollContent)
        self.scrollContent.addSubview(logo)
        self.scrollContent.addSubview(itemsStack)
        
        self.itemsStack.addArrangedSubview(company)
        self.itemsStack.addArrangedSubview(name)
        self.itemsStack.addArrangedSubview(secondName)
        self.itemsStack.addArrangedSubview(birthday)
        self.itemsStack.addArrangedSubview(phone)
        
        self.addSubview(continueButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(continueButton.snp.top)
        }
        
        scrollContent.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        logo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.3)
        }
        
        itemsStack.snp.makeConstraints { make in
            make.top.equalTo(self.logo.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

#if DEBUG
import SwiftUI
#Preview(body: {
    SetInfoView().showPreview()
})
#endif
