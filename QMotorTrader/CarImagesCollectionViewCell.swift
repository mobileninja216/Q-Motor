//
//  CarImagesCollectionViewCell.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
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
