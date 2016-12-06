//
//  PreviewViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carTrans: UITextField!
    @IBOutlet weak var carPrice: UITextField!
    @IBOutlet weak var carDealer: UITextField!
    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var listPreviewHeaderLabel: UILabel!
    @IBOutlet weak var listPreviewSubtitleLabel: UILabel!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "cars"
    var cars = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var carsIds: [Int] = [Int]()
    var carIndex: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "PreviewViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listPreviewHeaderLabel.text = utility.__("listPreviewHeaderLabel")
        listPreviewSubtitleLabel.text = utility.__("listPreviewSubtitleLabel")
    }
    
    func getOnlineAdvert(step: Int) {
        self.worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("sellcar?steps=\(step)&cars_id=\(newCarAdvertID)").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) -> Void in
                var record = [String: String]()
                if let carsList = resultset!["sellcar_dt"] {
                    for (_, car) in carsList {
                        for (key, value) in car {
                            if key == "cars_image" {
                                record["featuredImage"] = value[0]["image"].stringValue
                                for (_, carImage) in value {
                                    if carImage["primary_photo"].int == 1 {
                                        record["featuredImage"] = carImage["image"].stringValue
                                    }
                                }
                            } else {
                                record[key] = value.stringValue
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if let featuredImage = record["featuredImage"] {
                        var featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        featuredImage = featuredImage.stringByReplacingOccurrencesOfString("mobile/", withString: "")
                        if let imageUrl = NSURL(string: featuredImage) {
                            self.imageView.hnk_setImageFromURL(imageUrl)
                        }
                    }
                    self.carName.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + " " + record["year_"+appDefaultLanguage!]!
                    self.carDealer.text = self.utility.__("dealer") + ": " + record["user_type_"+appDefaultLanguage!]!
                    self.carPrice.text = self.utility.getFormattedStringFromNumber(Double(record["price"]!)!) + " " + self.utility.__("qar")
                    self.carTrans.text = self.utility.__("mileage") + ": " + self.utility.getFormattedStringFromNumber(Double(record["mileage"]!)!)
                    self.activityIndicator.hidden = true
                    self.carName.hidden = false
                    self.carDealer.hidden = false
                    self.carPrice.hidden = false
                    self.carTrans.hidden = false
                    self.imageView.hidden = false
                }
            }
        
        }
    }
}
