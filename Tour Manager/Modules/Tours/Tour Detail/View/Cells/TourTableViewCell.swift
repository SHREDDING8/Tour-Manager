//
//  TourManadgmentTableViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.07.2023.
//

import UIKit
import SnapKit

class TourTableViewCell: UITableViewCell {
    lazy var mainView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .background)
        
        view.layer.masksToBounds = false
        
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.label.cgColor
        
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    lazy var startTime:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var title:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var route:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var guides:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var status:UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    lazy var numOfPeople:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var customerCompanyTitle:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        self.backgroundColor = UIColor(resource: .background)
        self.selectionStyle = .none
        
        self.contentView.addSubview(mainView)
        
        self.mainView.addSubview(startTime)
        
        self.mainView.addSubview(status)
        
        self.mainView.addSubview(title)
        
        self.mainView.addSubview(route)
        
        self.mainView.addSubview(guides)
        self.mainView.addSubview(numOfPeople)
        self.mainView.addSubview(customerCompanyTitle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        startTime.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(3)
            make.width.equalTo(50)
        }
        
        status.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalTo(startTime.snp.trailing).offset(3)
            make.width.equalTo(3)
        }
        
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(status.snp.trailing).offset(30)
            make.trailing.equalToSuperview()
        }
        route.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.leading.equalTo(status.snp.trailing).offset(30)
            make.trailing.equalToSuperview()
        }
        guides.snp.makeConstraints { make in
            make.top.equalTo(route.snp.bottom).offset(5)
            make.leading.equalTo(status.snp.trailing).offset(30)
            make.trailing.equalToSuperview()
        }
        
        numOfPeople.snp.makeConstraints { make in
            make.top.equalTo(guides.snp.bottom).offset(5)
            make.leading.equalTo(status.snp.trailing).offset(30)
            make.trailing.equalToSuperview()
        }
        
        customerCompanyTitle.snp.makeConstraints { make in
            make.top.equalTo(numOfPeople.snp.bottom).offset(5)
            make.leading.equalTo(status.snp.trailing).offset(30)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    public func configure(time:String, title:String, route:String, guides:String, numOfPeople:String, customer:String, statusColor:UIColor, isGuide:Bool = false){
        self.startTime.text = time
        self.title.text = title
        self.route.text = route
        self.numOfPeople.text = numOfPeople
        self.guides.text = guides
        self.status.backgroundColor = statusColor
        
        self.customerCompanyTitle.text = isGuide == true ? "" : customer
        
        self.layoutSubviews()
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let scale = highlighted == false ? (1, 1) : (1.05, 1.05)
                
        UIView.animate(withDuration: 0.3) {
            self.mainView.transform = CGAffineTransform(scaleX: scale.0, y: scale.1)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            mainView.layer.shadowColor = UIColor.label.cgColor
        }
    }
}
