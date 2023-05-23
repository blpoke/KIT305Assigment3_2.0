//
//  SleepUITableViewCell.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import UIKit

class SleepUITableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
