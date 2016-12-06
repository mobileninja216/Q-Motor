//
//  ThanksViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class ThanksViewController: UIViewController {

    var utility: Utility = Utility.sharedInstance
    var worker: Worker = Worker.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet weak var backToHome: UIButton!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "ThanksViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.messageLabel.hidden = true
    }
        
    func viewThanksMessage() {
        var parameters: [String : String] = [:]
        parameters["steps"] = String(6)
        parameters["_method"] = "put"
        self.worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("sellcar/\(newCarAdvertID)").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let msgNo = resultset!["par"]!["msg_no"].intValue
                    let adNo = resultset!["par"]!["cars_id"].stringValue
                    self.thanksLabel.text = self.utility.__("thanksLabel")
                    self.messageLabel.hidden = false
                    self.messageLabel.text = self.utility.__("messageLabel\(msgNo)").stringByReplacingOccurrencesOfString(":advert_number", withString: adNo, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    self.backToHome.setTitle(self.utility.__("backToHome"), forState: UIControlState.Normal)

                }
            }
        }
    }
}
