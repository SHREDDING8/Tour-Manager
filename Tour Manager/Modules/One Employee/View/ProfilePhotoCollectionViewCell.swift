//
//  ProfilePhotoCollectionViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.12.2023.
//

import UIKit
import SnapKit

class ProfilePhotoCollectionViewCell: UICollectionViewCell {
    public lazy var profileImage:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.image = UIImage(resource: .noProfilePhoto)
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        self.contentView.addSubview(profileImage)
        
        profileImage.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    public func setProfilePhoto(image:UIImage, animated:Bool = false){
        let duration = animated == true ? 0.3 : 0
        
        UIView.transition(with: profileImage, duration: duration,options: .transitionCrossDissolve) {
            self.profileImage.image = image
        }
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = UIImage(resource: .noProfilePhoto)
    }
}
