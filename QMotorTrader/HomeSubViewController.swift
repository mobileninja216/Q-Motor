//
//  HomeSubViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class HomeSubViewController: UIViewController {

    @IBOutlet weak var customNumberPlates: UIButton!
    @IBOutlet weak var sellMyCarButton: UIButton!
    @IBOutlet weak var rentCarButton: UIButton!
    @IBOutlet weak var allRightsReservedLabel: UILabel!
    @IBOutlet weak var carsAvailableLabel: UILabel!
    @IBOutlet weak var findNewUsedCarsLabel: UILabel!
    @IBOutlet weak var selectMakeButton: UIButton!
    @IBOutlet weak var selectModelButton: UIButton!
    @IBOutlet weak var selectTrimButton: UIButton!
    @IBOutlet weak var selectYearButton: UIButton!
    @IBOutlet weak var searchCarButton: UIButton!
    
    var utility: Utility = Utility.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "HomeSubViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCarButton.setAttributedTitle(NSAttributedString(string: utility.__("searchCarButton"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: UIControlState.Normal)
        findNewUsedCarsLabel.text = utility.__("findNewUsedCarsLabel")
        allRightsReservedLabel.text = utility.__("allRightsReservedLabel")
        
        let postfix = appDefaultLanguage == "ar" ? "-ar" : ""
        sellMyCarButton.setBackgroundImage(UIImage(named: "sell-my-car"+postfix), forState: UIControlState.Normal)
        rentCarButton.setBackgroundImage(UIImage(named: "rent-a-car"+postfix), forState: UIControlState.Normal)
        customNumberPlates.setBackgroundImage(UIImage(named: "customNumberPlates"+postfix), forState: UIControlState.Normal)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if filterArray["make_id"] != nil && Int(filterArray["make_id"]!)! > 0 {
            self.selectMakeButton.setTitle(filterArray["make_name"]!, forState: UIControlState.Normal)
            self.selectModelButton.enabled = true
        } else {
            self.selectMakeButton.setTitle(utility.__("selectMake"), forState: UIControlState.Normal)
        }
        
        if filterArray["model_id"] != nil && Int(filterArray["model_id"]!)! > 0 {
            self.selectModelButton.setTitle(filterArray["model_name"]!, forState: UIControlState.Normal)
            self.selectTrimButton.enabled = true
        } else {
            self.selectModelButton.setTitle(utility.__("selectModel"), forState: UIControlState.Normal)
        }
        
        if filterArray["trim_id"] != nil && Int(filterArray["trim_id"]!)! > 0 {
            self.selectTrimButton.setTitle(filterArray["trim_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectTrimButton.setTitle(utility.__("selectTrim"), forState: UIControlState.Normal)
        }
        
        if filterArray["year_id"] != nil && Int(filterArray["year_id"]!)! > 0 {
            self.selectYearButton.setTitle(filterArray["year_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectYearButton.setTitle(utility.__("selectHomeYear"), forState: UIControlState.Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "carRental" {
            let navigation = segue.destinationViewController as! UINavigationController
            let webview = navigation.viewControllers.first as! WebViewController
            webview.pageName = "Car rental"
            webview.pageUrl = "http://qmotor.com/rent-car-qatar/" + appDefaultLanguage!
        }
    }
    
    @IBAction func openFacebookPage(sender: AnyObject) {
        let facebookHooks = "fb://profile/Minao"
        let facebookUrl = NSURL(string: facebookHooks)
        if UIApplication.sharedApplication().canOpenURL(facebookUrl!) {
            UIApplication.sharedApplication().openURL(facebookUrl!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: appSetting!["facebook"] as! String)!)
        }
    }
    
    @IBAction func openTwitterPage(sender: AnyObject) {
        let twitterHooks = "twitter://user?screen_name=QMotor"
        let twitterUrl = NSURL(string: twitterHooks)
        if UIApplication.sharedApplication().canOpenURL(twitterUrl!) {
            UIApplication.sharedApplication().openURL(twitterUrl!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: appSetting!["twitter"] as! String)!)
        }
    }
    
    @IBAction func openInstagramPage(sender: AnyObject) {
        let instagramHooks = "instagram://user?username=q_motor"
        let instagramUrl = NSURL(string: instagramHooks)
        if UIApplication.sharedApplication().canOpenURL(instagramUrl!) {
            UIApplication.sharedApplication().openURL(instagramUrl!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: appSetting!["instagram"] as! String)!)
        }
    }
    
    @IBAction func openYoutubePage(sender: AnyObject) {
        let youtubeHooks = "instagram://user?username=UCNxaCedOl_XKAsqShfSmwyg"
        let youtubeUrl = NSURL(string: youtubeHooks)
        if UIApplication.sharedApplication().canOpenURL(youtubeUrl!)
        {
            UIApplication.sharedApplication().openURL(youtubeUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.sharedApplication().openURL(NSURL(string: appSetting!["youtube"] as! String)!)
        }
    }

}
