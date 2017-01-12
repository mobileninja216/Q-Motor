//
//  MyProfileInfoViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyProfileInfoViewController: UIViewController {
    
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var sellerTypeLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var myCarsSoldLabel: UILabel!
    @IBOutlet weak var numberPlatesLabel: UILabel!
    @IBOutlet weak var myAdvertLabel: UILabel!
    @IBOutlet weak var carsSoldNumber: UILabel!
    @IBOutlet weak var platesNumber: UILabel!
    @IBOutlet weak var advertsNumber: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var sellerType: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MyProfileInfoViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        emailAddressLabel.text = utility.__("emailAddressLabel")
        fullNameLabel.text = utility.__("fullNameLabel")
        sellerTypeLabel.text = utility.__("sellerTypeLabel")
        phoneNumberLabel.text = utility.__("phoneNumberLabel")
        myCarsSoldLabel.text = utility.__("myCarsSoldLabel")
        numberPlatesLabel.text = utility.__("numberPlatesLabel")
        myAdvertLabel.text = utility.__("myAdvertLabel")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if profile.count > 0 {
            if let _ = profile["phone"] {
                self.phoneNumber.text = profile["phone"]
            } else {
                self.phoneNumber.text = "-"
            }
            
            if let _ = profile["user_t"] {
                self.sellerType.text = Int(profile["user_t"]!)==1 ? "Individual" : "Companies"
            } else {
                self.sellerType.text = "-"
            }
            
            if let _ = profile["fullname_"+appDefaultLanguage!] {
                self.fullName.text = profile["fullname_"+appDefaultLanguage!]
            } else {
                self.fullName.text = "-"
            }
            if let _ = profile["email"] {
                self.emailAddress.text = profile["email"]
            } else {
                self.emailAddress.text = "-"
            }
        }
    }
    
}
