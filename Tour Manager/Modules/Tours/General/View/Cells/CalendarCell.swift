//
//  CalendarCell.swift
//  PetConnect
//
//  Created by SHREDDING on 06.11.2023.
//  Copyright © 2023 PetConnect. All rights reserved.
//

import Foundation
import JTAppleCalendar
import UIKit
import SnapKit

final class CalendarCell:JTACDayCell{
    public var date:Date!
    
    enum CellColor{
        static let unselectedBackgound = UIColor(resource: .background)
        static let selectedBackgound = UIColor(resource: .blueText)
        
        static let unselectedSubtitle = UIColor.label
    }
    
    private lazy var dayNumber:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.text = "1"
        return label
    }()
    private lazy var mainView:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = CellColor.unselectedBackgound
        
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 3
        return view
    }()
    
    private lazy var dayNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = CellColor.unselectedSubtitle
        label.text = "Bc"
        return label
    }()
        
    private lazy var eventsLabel:UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.textAlignment = .center
        view.text = "•"
        view.textColor = .systemRed
        view.numberOfLines = 1
        return view
    }()
    private lazy var eventsLabel2:UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.textAlignment = .center
        view.text = "•"
        view.textColor = .systemRed
        view.numberOfLines = 1
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(mainView)
        self.mainView.addSubview(dayNumber)
        self.mainView.addSubview(dayNameLabel)
        
        self.mainView.addSubview(eventsLabel)
        self.mainView.addSubview(eventsLabel2)
                
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        dayNumber.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        dayNameLabel.snp.makeConstraints { make in
            make.top.equalTo(dayNumber.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        eventsLabel.snp.makeConstraints { make in
            make.top.equalTo(dayNameLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(1)
        }
        
        eventsLabel2.snp.makeConstraints { make in
            make.top.equalTo(eventsLabel.snp.bottom).inset(7)
            make.leading.trailing.equalToSuperview().inset(1)
            make.bottom.equalToSuperview().inset(1)
        }
        
    }
    
    public func configureEvents(_ colors:[UIColor]){
        let resString = NSMutableAttributedString()
        
        for indexColor in 0..<2{
            if indexColor >= colors.count{
                break
            }
            
            let string = NSAttributedString(string: "•" + (indexColor == 1 ? "" : " "), attributes: [.foregroundColor: colors[indexColor] ])
            resString.append(string)
        }
        
        if colors.count == 0{
            resString.append(NSAttributedString(string: " "))
        }
        
        self.eventsLabel2.attributedText = resString
        
        let resString2 = NSMutableAttributedString()
        if colors.count > 2{
            for indexColor in 2..<colors.count{
                let string = NSAttributedString(string: "•" + (indexColor == colors.count - 1 ? "" : " "), attributes: [.foregroundColor: colors[indexColor] ])
                resString2.append(string)
            }
        }else{
            resString2.append(NSAttributedString(string: " "))
        }
        
        self.eventsLabel.attributedText = resString2
        
    }
    
    public func configureCell(cellState: CellState){
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        
        dayNumber.text = "\(calendar.component(.day, from: cellState.date))"
        dayNameLabel.text = cellState.date.getDayName()
        self.date = cellState.date
        
        if calendar.isDateInToday(cellState.date){
            self.mainView.layer.borderWidth = 2
            self.mainView.layer.borderColor = CellColor.selectedBackgound.cgColor
        }else{
            self.mainView.layer.borderWidth = 0
            self.mainView.layer.borderColor = UIColor.clear.cgColor
        }
        
        if cellState.isSelected{
            self.select(animated: false)
        }else{
            self.deselect(animated: false)
        }
        
    }
    
    public func select(animated:Bool){
        UIView.animate(withDuration: animated == true ? 0.3 : 0) {
            self.mainView.backgroundColor = CellColor.selectedBackgound
            self.dayNumber.textColor = .white
            self.dayNameLabel.textColor = .white
        }
        
    }
    
    public func deselect(animated:Bool){
        UIView.animate(withDuration: animated == true ? 0.3 : 0) {
            self.mainView.backgroundColor = CellColor.unselectedBackgound
            self.dayNumber.textColor = CellColor.unselectedSubtitle
            self.dayNameLabel.textColor = CellColor.unselectedSubtitle
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            mainView.layer.shadowColor = UIColor.label.cgColor
        }
    }
}
