//
//  GuideCollectionViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 20.06.2023.
//

import UIKit

class GuideCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var isMainGuide: UILabel!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var status: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
    }
}
