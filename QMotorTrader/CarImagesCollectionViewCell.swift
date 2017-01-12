//
//  CarImagesCollectionViewCell.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import Haneke

class CarImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var carImage: UIImageView!
    
    override func prepareForReuse() {
        carImage.hnk_cancelSetImage()
        carImage.image = nil
    }
}
