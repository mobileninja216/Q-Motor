//
//  ConfirmViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class ConfirmViewController: UIViewController {
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var nameAndAddressLabel: UILabel!
    @IBOutlet weak var dealerTypeKeyLabel: UILabel!
    @IBOutlet weak var dealerTypeValueLabel: UILabel!
    @IBOutlet weak var vehicleDetailsKeyLabel: UILabel!
    @IBOutlet weak var vehicleDetailsValueLabel: UILabel!
    @IBOutlet weak var expiredAtKeyLabel: UILabel!
    @IBOutlet weak var expiredAtValueLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var packageTypeKeyLabel: UILabel!
    @IBOutlet weak var packageTypeValueLabel: UILabel!
    @IBOutlet weak var totalKeyLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    
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
//        let name = "ConfirmViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameAndAddressLabel.text = utility.__("nameAndAddressLabel")
        dealerTypeKeyLabel.text = utility.__("dealerTypeKeyLabel")
        vehicleDetailsKeyLabel.text = utility.__("vehicleDetailsKeyLabel")
        expiredAtKeyLabel.text = utility.__("expiredAtKeyLabel")
        totalPaymentLabel.text = utility.__("totalPaymentLabel")
        packageTypeKeyLabel.text = utility.__("packageTypeKeyLabel")
        totalKeyLabel.text = utility.__("totalKeyLabel")

        self.loaderView.hidden = false
        
        if newCarAdvertID > 0 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("cars/\(newCarAdvertID)").request(Worker.Method.GET, parameters: [:]) {
                    (resultset, pagination, messageError) -> Void in
                }
            }
        }
        
    }
    
    func getOnlineAdvert(step: Int) {
        self.worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("sellcar?steps=\(step)&cars_id=\(newCarAdvertID)").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let record = resultset!["sellcar_dt"]![0].dictionary {
                        self.totalValueLabel.text = record["pkg_price"]?.stringValue;
                        self.packageTypeValueLabel.text =  record["pkg_id"] != 1 ? self.utility.__("paid") : self.utility.__("free")
                        self.expiredAtValueLabel.text = record["exp_date"]?.stringValue;
                        self.vehicleDetailsValueLabel.text = record["make_name_" + appDefaultLanguage!]!.stringValue + " " + record["model_name_" + appDefaultLanguage!]!.stringValue + " " + record["year_" + appDefaultLanguage!]!.stringValue;
                        self.dealerTypeValueLabel.text = record["user_t"]?.intValue == 1 ? self.utility.__("individual") : self.utility.__("companies")
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd MMM, yyyy"
                        self.expiredAtValueLabel.text = dateFormatter.stringFromDate(self.utility.addDate(record["advs_duration"]!.intValue, unit: NSCalendarUnit.WeekOfMonth))
                        self.loaderView.hidden = true
                    }
                }
            }
        }
    }
}
