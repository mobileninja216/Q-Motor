//
//  CameraGalleryCollectionViewCell.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class CameraGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadStatus: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var loaderStatusView: UIView!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    
}
