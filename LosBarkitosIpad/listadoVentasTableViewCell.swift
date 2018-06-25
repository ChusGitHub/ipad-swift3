//
//  listadoBarcasTableViewCell.swift
//  LosBarkitosIpad
//
//  Created by Jesus Valladolid Rebollar on 15/7/15.
//  Copyright (c) 2015 Jesus Valladolid Rebollar. All rights reserved.
//

import UIKit

class listadoVentasTableViewCell: UITableViewCell {

    @IBOutlet weak var numeroUILabel: UILabel!
    @IBOutlet weak var puntoVentaUILabel: UILabel!
    @IBOutlet weak var tipoBarcaUILabel: UILabel!
    @IBOutlet weak var horaUILabel: UILabel!
    @IBOutlet weak var precioUILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
