//
//  typeOfAccountView.swift
//  Tour Manager
//
//  Created by SHREDDING on 15.12.2023.
//

import UIKit
import SnapKit

final class TypeOfAccountView: UIView {
    
    lazy var logo:UIImageView = {
        let view = UIImageView(image: UIImage(resource: .iconImg))
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var employee:UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.baseBackgroundColor = .init(resource: .blueText)
        conf.baseForegroundColor = .white
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Я сотрудник", size: 16, style: .regular)
        
        return button
    }()
    
    lazy var newCompany:UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.baseBackgroundColor = .init(resource: .blueText)
        conf.baseForegroundColor = .white
        
        let button = UIButton(configuration: conf)
        button.setTitle(title: "Создать организацию", size: 16, style: .regular)
        
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
        self.addSubview(employee)
        self.addSubview(newCompany)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        logo.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        employee.snp.makeConstraints { make in
            make.bottom.equalTo(self.newCompany.snp.top).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        newCompany.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
}

#if DEBUG
import SwiftUI
#Preview(body: {
    TypeOfAccountView().showPreview()
})
#endif
