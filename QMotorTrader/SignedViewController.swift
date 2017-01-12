//
//  SignedViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class SignedViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var fullName: UIButton!
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SignedViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        signupButton.setTitle(utility.__("signout"), forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("profile").request(Worker.Method.GET) {
                (resultset, pagination, messageError) in
                if let error = messageError {
                    if Int(error["code"]!)! == 200 {
                        if let user = resultset!["profile"]!["user"].dictionary {
                            if user.count > 0 {
                                for (key, value) in user {
                                    profile[key] = value.stringValue
                                }
                            }
                        }
                    }
                } else {
                    profile = [:]
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                if profile.count > 0 {
                    self.fullName.setAttributedTitle(NSAttributedString(string: profile["fullname_"+appDefaultLanguage!]!.capitalizedString, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: UIControlState.Normal)
                }
            }
        }
    }
    
    @IBAction func signOut(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("logout").request(Worker.Method.GET) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if Int(error["code"]!) == 200 {
                            let menu = self.parentViewController as! MenuTableViewController
                            menu.signContainer.hidden = false
                            menu.signedContainer.hidden = true
                            menu.tableView.reloadData()
                            profile = [:]
                            preference!.removeObjectForKey("accessToken")
                            preference!.synchronize()
                        }
                    }
                }
            }
        }
    }
    
}
