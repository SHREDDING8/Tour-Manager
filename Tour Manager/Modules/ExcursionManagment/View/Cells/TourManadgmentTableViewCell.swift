//
//  TourManadgmentTableViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 07.07.2023.
//

import UIKit

class TourManadgmentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var guidesLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var numberOfPeople: UILabel!
    
    @IBOutlet weak var customerCompanyName: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
