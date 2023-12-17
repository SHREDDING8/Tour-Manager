//
//  GuideTourItem.swift
//  Tour Manager
//
//  Created by SHREDDING on 10.12.2023.
//

import UIKit
import SnapKit

final class GuideTourItem: UIView {
    
    var guideId:String = ""
    
    lazy var guidePhoto:UIImageView = {
        let view = UIImageView()
        
        view.image = UIImage(resource: .noProfilePhoto)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        view.layer.cornerRadius = 20
                
        return view
    }()
    
    let guideName:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        
        label.text = "Egorka Pomidorka"
        return label
    }()
    
    let guideStatus:UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "circle.fill"))
        view.contentMode = .scaleAspectFill
        
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
        self.addSubview(guidePhoto)
        self.addSubview(guideName)
        self.addSubview(guideStatus)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guidePhoto.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(40)
        }
        
        guideName.snp.makeConstraints { make in
            make.trailing.equalTo(guideStatus.snp.leading).inset(5)
            make.bottom.top.equalToSuperview().inset(10)
            make.leading.equalTo(guidePhoto.snp.trailing).offset(20)
        }
        
        guideStatus.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
        }
    }
}

import SwiftUI
#Preview(body: {
    GuideTourItem().showPreview()
})
