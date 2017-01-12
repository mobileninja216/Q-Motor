//
//  FeaturedCarViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import Haneke

class FeaturedCarViewController: UIViewController {
    
    var itemIndex: Int = 0
    var record: [String: String] = [:]
    
    @IBOutlet weak var featuredView: UIView!
    @IBOutlet weak var featuredCarDealer: UITextField!
    @IBOutlet weak var featuredCarPrice: UITextField!
    @IBOutlet weak var featuredCarName: UILabel!
    @IBOutlet weak var featuredCarImage: UIImageView!
    @IBOutlet weak var featuredCarHeight: NSLayoutConstraint!
    var username: UITextField!
    var password: UITextField!
    var firstName: UITextField!
    var lastName: UITextField!
    var phoneNumber: UITextField!

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "FeaturedCarViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utility.DeviceType.IS_IPAD {
            featuredCarHeight.constant = 290
        } else if Utility.DeviceType.IS_IPHONE_FIVE || Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
            featuredCarHeight.constant = 180
        } else if Utility.DeviceType.IS_IPHONE_SIX {
            featuredCarHeight.constant = 230
        } else if Utility.DeviceType.IS_IPHONE_SIX_PLUS {
            featuredCarHeight.constant = 260
        }
        
        let featuredCarDealerPaddingView = UIView(frame: CGRectMake(10, 10, 0, self.featuredCarDealer.frame.height))
        self.featuredCarDealer.leftView = featuredCarDealerPaddingView
        self.featuredCarDealer.leftViewMode = UITextFieldViewMode.Always
        
        let featuredCarPricePaddingView = UIView(frame: CGRectMake(10, 10, 0, self.featuredCarPrice.frame.height))
        self.featuredCarPrice.leftView = featuredCarPricePaddingView
        self.featuredCarPrice.leftViewMode = UITextFieldViewMode.Always
        
        if record.isEmpty == false {
            if record["featuredImage"] == nil {
                var carImages = self.worker.select(Worker.Entities.CARS_IMAGES, whereCondition: "cars_id=\(Int(record["id"]!)!)", sortBy: "id", isAscending: false, cursor: nil, limit: 1, indexedBy: "index")!
                record["featuredImage"] = carImages[0]!["image"]
            }
            if let featuredImage = record["featuredImage"] {
                let featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                if let imageNSUrl = NSURL(string: String(featuredImage)) {
                    featuredCarImage.hnk_setImageFromURL(imageNSUrl)
                }
            }
            featuredView.tag = Int(record["id"]!)!
            featuredCarPrice.text = self.utility.getFormattedStringFromNumber(Double(record["price"]!)!)  + " " + self.utility.__("qar")
            
            featuredCarDealer.text = self.utility.__("dealer") + ": " + (Int(record["user_t"]!)==1 ? record["user_type_"+appDefaultLanguage!]! : record["fullname_"+appDefaultLanguage!]!)
            
            var trimValue: String = ""
            if let trim = record["trim_name_"+appDefaultLanguage!] {
                trimValue = " " + trim
            }
            featuredCarName.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + trimValue + " " + self.utility.getFormattedStringFromNumber(Double(record["year_"+appDefaultLanguage!]!)!, groupingSize: 4)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let viewCarController = self.storyboard!.instantiateViewControllerWithIdentifier("ViewCarViewController") as! ViewCarViewController
            viewCarController.carId = (touch.view?.tag)!
            self.navigationController?.pushViewController(viewCarController, animated: true)

        }
        super.touchesBegan(touches, withEvent:event)
    }
    
}
