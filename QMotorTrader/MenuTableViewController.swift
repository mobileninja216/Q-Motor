//
//  MenuTableViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var numberPlates: UIButton!
    @IBOutlet weak var aboutQmotoTraderButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var numberPlatesButton: UIButton!
    @IBOutlet weak var myAdvertsButton: UIButton!
    @IBOutlet weak var myGarageButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var myAccountButton: UIButton!
    @IBOutlet weak var carDealers: UIButton!
    @IBOutlet weak var rentCarButton: UIButton!
    @IBOutlet weak var sellMyCarButton: UIButton!
    @IBOutlet weak var buyCarButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signedContainer: UIView!
    @IBOutlet weak var signContainer: UIView!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MenuTableViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        filterArray = [String: String]()
        setupUI()
        self.activityIndicator.stopAnimating()
        if profile.count == 0 {
            self.signedContainer.hidden = true
            self.signContainer.hidden = false
        } else {
            self.signedContainer.hidden = false
            self.signContainer.hidden = true
        }
        self.tableView.reloadData()
    }
    
    func setupUI() {
        homeButton.setTitle(utility.__("homeButton"), forState: UIControlState.Normal)
        buyCarButton.setTitle(utility.__("buyCarButton"), forState: UIControlState.Normal)
        sellMyCarButton.setTitle(utility.__("sellMyCarButton"), forState: UIControlState.Normal)
//        rentCarButton.setTitle(utility.__("rentCarButton"), forState: UIControlState.Normal)
        carDealers.setTitle(utility.__("carDealers"), forState: UIControlState.Normal)
        myAccountButton.setTitle(utility.__("myAccountButton"), forState: UIControlState.Normal)
        myProfileButton.setTitle(utility.__("myProfileButton"), forState: UIControlState.Normal)
        myGarageButton.setTitle(utility.__("myGarageButton"), forState: UIControlState.Normal)
        myAdvertsButton.setTitle(utility.__("myAdvertsButton"), forState: UIControlState.Normal)
        numberPlatesButton.setTitle(utility.__("numberPlatesButton"), forState: UIControlState.Normal)
        contactUsButton.setTitle(utility.__("contactUsButton"), forState: UIControlState.Normal)
        settingButton.setTitle(utility.__("settingButton"), forState: UIControlState.Normal)
        aboutQmotoTraderButton.setTitle(utility.__("aboutQmotoTraderButton"), forState: UIControlState.Normal)
        numberPlates.setTitle(utility.__("customNumberPlates"), forState: UIControlState.Normal)
    }
    
    func getTableviewObject() -> UITableView {
        return self.tableView
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "profile" && profile.count > 0 {
            self.performSegueWithIdentifier("profile", sender: nil)
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(156)
        } else if indexPath.row == 6 {
            if profile.count > 0 {
                return CGFloat(185)
            } else {
                return CGFloat(44)
            }
        }
        return CGFloat(44)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sellMyCar" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let sellMyCarController = navigationController.viewControllers.first as! SellMyCarViewController
            sellMyCarController.selectedAdvertId = 0
        }
        if segue.identifier == "profile" {
            let navigationController = segue.destinationViewController as! UINavigationController
            _ = navigationController.viewControllers.first as! MyAccountViewController
        }
        if segue.identifier == "carRental" {
            let navigation = segue.destinationViewController as! UINavigationController
            let webview = navigation.viewControllers.first as! WebViewController
            webview.pageName = "Car rental"
            webview.pageUrl = "http://qmotor.com/rent-car-qatar/" + appDefaultLanguage!
        }
    }
    
}
