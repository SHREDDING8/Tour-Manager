//
//  AccessLevelElement.swift
//  Tour Manager
//
//  Created by SHREDDING on 25.11.2023.
//

import UIKit
import SnapKit

final class AccessLevelElement: UIView {
    
    lazy var title:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        
        label.text = "test rule test rule test rule test rule test rule test rule test rule test rule test rule test rule test rule test rule test rule test rule"
        return label
    }()
    
    lazy var switchControll:UISwitch = {
        let view = UISwitch()
        view.isOn = false
        view.onTintColor = UIColor(resource: .blueText)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        self.addSubview(title)
        self.addSubview(switchControll)
        
        title.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(switchControll)
        }
        switchControll.snp.makeConstraints { make in
            make.centerY.equalTo(title)
            make.leading.equalTo(title.snp.trailing)
            make.trailing.equalToSuperview()
            make.width.equalTo(50)
        }
        
    }
}

import SwiftUI
#Preview(body: {
    AccessLevelElement().showPreview()
})
