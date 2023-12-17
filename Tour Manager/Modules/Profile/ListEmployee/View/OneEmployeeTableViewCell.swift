//
//  OneEmployeeTableViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.11.2023.
//

import UIKit
import SnapKit

final class OneEmployeeTableViewCell: UITableViewCell {
    
    lazy var image:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        view.image = UIImage(resource: .noProfilePhoto)
        
        view.layer.cornerRadius = 25
        return view
    }()
    
    lazy var name:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        image.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.leading.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        
        name.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.centerY.equalTo(image)
            make.trailing.equalToSuperview().inset(5)
        }
    }
    
    func commonInit(){
        self.backgroundColor = .clear
        self.accessoryType = .disclosureIndicator
        self.contentView.addSubview(image)
        self.contentView.addSubview(name)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.image.image = UIImage(resource: .noProfilePhoto)
    }

}
