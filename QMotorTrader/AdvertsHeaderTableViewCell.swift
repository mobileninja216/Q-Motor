//
//  AdvertsHeaderTableViewCell.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class AdvertsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var advertExpiredAt: UILabel!
    @IBOutlet weak var latestUpdateDelete: UILabel!
    @IBOutlet weak var advertsLatestUpdateLabel: UILabel!
    @IBOutlet weak var advertsIDLabel: UILabel!
    @IBOutlet weak var makeModelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
