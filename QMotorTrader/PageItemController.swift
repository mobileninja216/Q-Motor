//
//  PageItemController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import Haneke

class PageItemController: UIViewController, UIScrollViewDelegate {
    
    var itemIndex: Int = 0
    var imageUrl: String = ""
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainer: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "PageItemController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utility.DeviceType.IS_IPAD {
            imageHeight.constant = 290
        } else if Utility.DeviceType.IS_IPHONE_FIVE || Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
            imageHeight.constant = 120
        } else if Utility.DeviceType.IS_IPHONE_SIX {
            imageHeight.constant = 141
        } else if Utility.DeviceType.IS_IPHONE_SIX_PLUS {
            imageHeight.constant = 155
        }
        
        imageUrl = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        if let imageNSUrl = NSURL(string: imageUrl) {
            imageViewContainer.hnk_setImageFromURL(imageNSUrl)
        }
    }
}
