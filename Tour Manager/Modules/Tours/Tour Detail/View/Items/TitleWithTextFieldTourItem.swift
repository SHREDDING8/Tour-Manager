//
//  TitleWithTextFieldTourItem.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.12.2023.
//

import UIKit
import SnapKit
import AlertKit

final class TitleWithTextFieldTourItem: UIView {
    
    lazy var title:UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 18,weight: .bold)
        
        label.text = "Title"
        return label
    }()
    
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .never
        textField.borderStyle = .none
        return textField
    }()
    
    lazy var nextPageImage:UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.buttonSize = .mini
        
        let button = UIButton(configuration: conf)
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return button
    }()

    private lazy var copyButton:UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.buttonSize = .mini
        
        let button = UIButton(configuration: conf)
        button.tintColor = .gray
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.addTarget(self, action: #selector(textCopy), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        self.addSubview(title)
        self.addSubview(textField)
        self.addSubview(nextPageImage)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nextPageImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
        
        title.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(5)
            make.trailing.equalTo(nextPageImage.snp.leading).inset(5)
        }
        
        if copyButton.superview != nil{
            copyButton.snp.makeConstraints { make in
                make.trailing.equalTo(nextPageImage.snp.leading).inset(5)
                make.centerY.equalToSuperview()
                make.width.equalTo(50)
            }
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(5)
            
            make.leading.equalToSuperview().inset(5)
            if copyButton.superview != nil{
                make.trailing.equalTo(copyButton.snp.leading).inset(5)
            }else{
                make.trailing.equalTo(nextPageImage.snp.leading).inset(5)
            }
            
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    public func addCopyButton(){
        self.addSubview(copyButton)
        self.layoutSubviews()
    }
    
    @objc func textCopy(){
        UIPasteboard.general.string = self.textField.text
        AlertKitAPI.present(
            title: "Скопировано",
            subtitle: nil,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
}
