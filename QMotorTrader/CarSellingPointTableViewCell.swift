//
//  CarSellingPointTableViewCell.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class CarSellingPointTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftSellingPoint: UILabel!
    @IBOutlet weak var rightSellingPoint: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
