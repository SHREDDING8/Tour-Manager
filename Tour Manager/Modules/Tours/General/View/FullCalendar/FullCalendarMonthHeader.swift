//
//  FullCalendarMonthHeader.swift
//  Tour Manager
//
//  Created by SHREDDING on 04.12.2023.
//

import UIKit
import JTAppleCalendar
import SnapKit

class FullCalendarMonthHeader: JTACMonthReusableView {
    lazy var title:UILabel = {
        let label = UILabel()
        label.text = "test"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
