//
//  TitleWithSwitchTourItem.swift
//  Tour Manager
//
//  Created by SHREDDING on 09.12.2023.
//

import UIKit
import SnapKit

class TitleWithSwitchTourItem: UIView {
    lazy var title:UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 18,weight: .bold)
        
        label.text = "Title"
        return label
    }()
    
    lazy var switchControll:UISwitch = {
        let view = UISwitch()
        view.isOn = false
        return view
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
        self.addSubview(switchControll)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switchControll.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        
        title.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(5)
            make.trailing.equalTo(switchControll.snp.leading).inset(5)
        }
        
    }
}
