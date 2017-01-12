//
//  UploadedImagesCollectionViewCell.swift
//  Q Motor
//
//  Created by StarMac on 1/9/16.
//  Copyright © 2016 Mahmood Nassar. All rights reserved.
//

import UIKit
//import Haneke

class UploadedImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var makeDefaultImage: UILabel!
    @IBOutlet weak var makeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var makeDefault: UIButton!
    @IBOutlet weak var deleteImage: UIButton!
    @IBOutlet weak var carImage: UIImageView!
    
    override func prepareForReuse() {
        carImage.hnk_cancelSetImage()
        carImage.image = nil
    }
}
