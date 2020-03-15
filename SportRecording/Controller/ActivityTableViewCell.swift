//
//  ActivityTableViewCell.swift
//  SportRecording
//
//  Created by Jan Prokorát on 14/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ActivityCell"
    
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_date: UILabel!
    @IBOutlet weak var lb_location: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
