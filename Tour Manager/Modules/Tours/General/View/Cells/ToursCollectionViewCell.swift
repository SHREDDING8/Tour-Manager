//
//  ToursCollectionViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 28.11.2023.
//

import UIKit
import SnapKit

class ToursCollectionViewCell: UICollectionViewCell {
    
    var date:Date = Date.now
    
    lazy var placeHolder:UILabel = {
        let label = UILabel()
        label.text = "Экскурсии отсутствуют"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(resource: .black40)
        
        return label
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.restorationIdentifier = "tableViewCalendar"
        
        let cell = UINib(nibName: "TourManadgmentTableViewCell", bundle: nil)
        
        tableView.register(cell, forCellReuseIdentifier: "TourManadgmentTableViewCell")
        
        tableView.backgroundColor = .clear
                
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        self.contentView.addSubview(tableView)
        self.contentView.addSubview(placeHolder)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeHolder.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
