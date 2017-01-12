//
//  MyGarrageCollectionViewCell.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyGarrageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var carPrice: UILabel!
    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func prepareForReuse() {
        carImage.hnk_cancelSetImage()
        carImage.image = nil
    }
}
