//K
//  VendedorUITableViewCell.swift
//  LosBarkitosIpad
//
//  Created by chus on 1/12/14.
//  Copyright (c) 2014 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit

class VendedorUITableViewCell: UITableViewCell {

    @IBOutlet weak var nombreVendedorUILabelCell: UILabel!
    @IBOutlet weak var codigoVendedorUILabelCell: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
