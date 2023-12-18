//
//  VerifyEmailView.swift
//  Tour Manager
//
//  Created by SHREDDING on 14.12.2023.
//

import UIKit
import SnapKit

final class VerifyEmailView: UIView {
    
    lazy var logo:UIImageView = {
        let view = UIImageView(image: UIImage(resource: .iconImg))
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var emailSended:UILabel = {
        let label = UILabel()
        label.text = "Письмо отправлено на адрес: "
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(resource: .blueText)
        
        return label
    }()
    
    lazy var email:UILabel = {
        let label = UILabel()
        label.text = "shredding.cs.go@mail.ru"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(resource: .blueText)
        
        return label
    }()
    
    lazy var confirmed:UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.baseBackgroundColor = .init(resource: .blueText)
        conf.baseForegroundColor = .white
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Подтверждено", size: 16, style: .regular)
        
        return button
    }()
    
    lazy var sendAgain:UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.baseBackgroundColor = .clear
        conf.baseForegroundColor = .init(resource: .blueText)
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Отправить повторно через 60", size: 12, style: .regular)
        button.isEnabled = false
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
        self.addSubview(emailSended)
        self.addSubview(email)
        self.addSubview(confirmed)
        self.addSubview(sendAgain)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        logo.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        emailSended.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        email.snp.makeConstraints { make in
            make.top.equalTo(emailSended.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmed.snp.makeConstraints { make in
            make.bottom.equalTo(sendAgain.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        sendAgain.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

#if DEBUG
import SwiftUI
#Preview(body: {
    VerifyEmailView().showPreview()
})
#endif
