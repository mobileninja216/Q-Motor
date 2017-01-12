//
//  NumberPlatesCollectionViewCell.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class NumberPlatesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var callSellerNowLabel: UILabel!
    @IBOutlet weak var carNumber: UILabel!
    @IBOutlet weak var numberPrice: UILabel!
    @IBOutlet weak var ownerPhoneNumber: UILabel!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first! as UITouch
        if (touch.view == ownerPhoneNumber) {
            if let phoneNumber = ownerPhoneNumber.text {
                let phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
                UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
            }
        }
    }
    
}
