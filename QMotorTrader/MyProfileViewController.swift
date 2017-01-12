//
//  MyProfileViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    
    var utility: Utility = Utility.sharedInstance
    var worker: Worker = Worker.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MyProfileViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        self.title = utility.__("myProfileTitle")
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("profile").request(Worker.Method.GET, parameters: [:]) {
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
                dispatch_async(dispatch_get_main_queue()) {
                    if profile.count > 0 {
                        if let fullname = profile["fullname_"+appDefaultLanguage!] {
                            self.fullName.text = fullname
                        } else {
                            self.fullName.text = "-"
                        }
                        if let email = profile["email"] {
                            self.emailAddress.text = email
                        } else {
                            self.emailAddress.text = "-"
                        }
                    }
                }
            }
        }
    }

}
