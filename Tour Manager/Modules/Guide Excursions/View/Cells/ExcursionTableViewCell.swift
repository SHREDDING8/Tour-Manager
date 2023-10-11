//
//  ExcursionTableViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 05.06.2023.
//

import UIKit

class ExcursionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var guidesLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
