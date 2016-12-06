//
//  MyAdvertsTableViewCell.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyAdvertsTableViewCell: UITableViewCell {

    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var carMakeAndModel: UILabel!
    @IBOutlet weak var advertId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }

}
