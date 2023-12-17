//
//  ExtendedSettingsView.swift
//  Tour Manager
//
//  Created by SHREDDING on 18.11.2023.
//

import UIKit
import SnapKit
import DeviceKit

final class ExtendedSettingsView: UIView {
    
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        
        return view
    }()
    
    lazy var contentView:UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var allDevicesHStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    lazy var allDevicesLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Устройства"
        
        return label
    }()
    
    lazy var logoutAll:UIButton = {
        let button = UIButton()
        if #available(iOS 16.0, *){
            button.setImage(UIImage(systemName:"door.left.hand.open"), for: .normal)
        }else{
            button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        }
        
        button.tintColor = .systemRed
        return button
    }()
    
    lazy var devicesVStack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
                
        return stack
    }()
    
    lazy var changePasswordStackView:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.isUserInteractionEnabled = true
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Изменить пароль"
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.isUserInteractionEnabled = false
        button.tintColor = .gray
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(button)
        
        return stack
    }()
    
    lazy var deleteAccount:UIButton = {
        let button = UIButton()
        button.setTitle(title:"Удалить аккаунт", size: 16, style: .bold)
        button.setTitleColor(.systemRed, for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).labeled("scrollView")
            make.leading.trailing.equalToSuperview().labeled("scrollView")
            make.bottom.equalToSuperview().labeled("scrollView")
        }
        
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().labeled("contentView")
            make.width.equalToSuperview().labeled("contentView")
        }
        
        allDevicesHStack.snp.makeConstraints { make in
            make.top.equalToSuperview().labeled("allDevicesHStack")
            make.leading.trailing.equalToSuperview().inset(20).labeled("allDevicesHStack")
        }
        
        devicesVStack.snp.makeConstraints { make in
            make.top.equalTo(allDevicesHStack.snp.bottom).offset(20).labeled("devicesVStack")
            make.leading.trailing.equalToSuperview().inset(20).labeled("devicesVStack")
        }
                
        changePasswordStackView.snp.makeConstraints { make in
            make.top.equalTo(devicesVStack.snp.bottom).offset(20).labeled("changePasswordStackView")
            make.leading.trailing.equalToSuperview().inset(20).labeled("changePasswordStackView")
        }
        
        deleteAccount.snp.makeConstraints { make in
            make.top.equalTo(changePasswordStackView.snp.bottom).offset(50).labeled("deleteAccount")
            make.leading.trailing.equalToSuperview().inset(20).labeled("deleteAccount")
            make.bottom.equalToSuperview().labeled("deleteAccount")
        }
    }
    
    func commonInit(){
        self.backgroundColor = UIColor(resource: .background)
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        self.contentView.addSubview(allDevicesHStack)
        
        allDevicesHStack.addArrangedSubview(allDevicesLabel)
        allDevicesHStack.addArrangedSubview(logoutAll)
        
        self.contentView.addSubview(devicesVStack)
        self.contentView.addSubview(changePasswordStackView)
        self.contentView.addSubview(deleteAccount)
                
        self.layoutSubviews()
}
    
    public func configureDevices(devices:[DevicesModel]){
        for subview in self.devicesVStack.subviews{
            subview.removeFromSuperview()
        }
        
        for device in devices {
            let stack = createOneDeviceStack(device)
            
            self.devicesVStack.addArrangedSubview(stack)
        }
        
        self.layoutSubviews()
    }
    
    private func createOneDeviceStack(_ device:DevicesModel) -> UIStackView{
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.spacing = 10
        
        var tintColor:UIColor = .systemBlue
                        
        let image:UIImage? = {
            switch device.type {
            case .apple:
                tintColor = .systemGray
                return UIImage(systemName: "applelogo")
            case .telegram:
                return UIImage(systemName: "paperplane.circle.fill")
            }
        }()
        
        var conf = UIButton.Configuration.plain()
        conf.buttonSize = .large
        conf.image = image
        conf.baseForegroundColor = tintColor
        let button = UIButton(configuration: conf)
                
        button.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        
        label.text = device.name
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(button)
        return stack
    }
}
