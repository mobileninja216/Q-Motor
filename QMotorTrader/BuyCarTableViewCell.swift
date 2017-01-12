//
//  BuyCarTableViewCell.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import Haneke

class BuyCarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var saveCarActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carYear: UITextField!
    @IBOutlet weak var carMileage: UITextField!
    @IBOutlet weak var carPrice: UITextField!
    @IBOutlet weak var carDealer: UITextField!
    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var saveAcar: UIButton!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var carSold: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        carImage.hnk_cancelSetImage()
        carImage.image = nil
    }

}
