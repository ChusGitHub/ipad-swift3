//
//  ControlUITableViewCell.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 8/3/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit

class ControlUITableViewCell: UITableViewCell {

    @IBOutlet weak var numeroUILabelUITableViewCell: UILabel!
    @IBOutlet weak var nombreUILabelUITableViewCell: UILabel!
    @IBOutlet weak var tipoUILabelUITableViewCell: UILabel!
    @IBOutlet weak var libreUILabelUITableViewCell: UILabel!
    @IBOutlet weak var vueltasUILabelUITableViewCell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
