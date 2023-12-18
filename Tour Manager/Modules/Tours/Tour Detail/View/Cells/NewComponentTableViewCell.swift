//
//  NewComponentTableViewCell.swift
//  Tour Manager
//
//  Created by SHREDDING on 13.06.2023.
//

import UIKit

final class NewComponentTableViewCell: UITableViewCell {

    @IBOutlet weak var componentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        
        self.accessoryType = .none
    }
    
}
