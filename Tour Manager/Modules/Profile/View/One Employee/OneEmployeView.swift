//
//  OneEmployeView.swift
//  Tour Manager
//
//  Created by SHREDDING on 14.10.2023.
//

import Foundation

import UIKit
import SnapKit

class HeaderView: UIView {
    lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no profile photo")
        imageView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .red
        
        return scrollView
    }()
    
    lazy var contentView:UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    lazy var firstSectionTitle:UILabel = {
        let label = UILabel()
        label.text = "Персональные данные"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { make in
            
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
        
        configureScrollView()
        configureFirstSection()
    }
    
    func configureScrollView(){
        self.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
            
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        
    }
    
    func configureFirstSection(){
        self.contentView.addSubview(firstSectionTitle)
        
        firstSectionTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}

#if DEBUG
import SwiftUI

struct HeaderView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        HeaderView().showPreview()
    }
}
#endif
