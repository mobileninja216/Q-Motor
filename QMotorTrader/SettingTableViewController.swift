//
//  SettingTableViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var allRightsReservedLabel: UILabel!
    @IBOutlet weak var instagramAccountLabel: UIButton!
    @IBOutlet weak var youtubeChannelLabel: UIButton!
    @IBOutlet weak var twitterAccountLabel: UIButton!
    @IBOutlet weak var facebookPageLabel: UIButton!
    @IBOutlet weak var saveSessionAfterLoginLabel: UILabel!
    @IBOutlet weak var defaultLanguageLabel: UILabel!
    @IBOutlet weak var loginBySessionSwitch: UISwitch!
    @IBOutlet weak var defaultLanguageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    var utility: Utility = Utility.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SettingTableViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadTableView()

        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        
        loadSettings()
    }
    
    func reloadTableView() {
        self.title = utility.__("settingTitle")
        allRightsReservedLabel.text = utility.__("allRightsReservedLabel")
        instagramAccountLabel.setTitle(utility.__("instagramAccountLabel"), forState: UIControlState.Normal)
        youtubeChannelLabel.setTitle(utility.__("youtubeChannelLabel"), forState: UIControlState.Normal)
        twitterAccountLabel.setTitle(utility.__("twitterAccountLabel"), forState: UIControlState.Normal)
        facebookPageLabel.setTitle(utility.__("facebookPageLabel"), forState: UIControlState.Normal)
        saveSessionAfterLoginLabel.text = utility.__("saveSessionAfterLoginLabel")
        defaultLanguageLabel.text = utility.__("defaultLanguageLabel")
    }
    
    @IBAction func saveLanguage(sender: UISegmentedControl) {
        appDefaultLanguage = sender.selectedSegmentIndex==0 ? "en" : "ar"
        preference!.setValue(appDefaultLanguage, forKey: "default-language")
        preference!.synchronize()
        let path = NSBundle.mainBundle().pathForResource(appDefaultLanguage=="en" ? "en" : "ar-QA", ofType: "lproj")
        bundle = NSBundle(path: path!)
        self.reloadTableView()
    }

    @IBAction func saveLSessionLogin(sender: UISwitch) {
        preference!.setValue(sender.on, forKey: "login-by-session")
        preference!.synchronize()
    }
    
    func loadSettings() {
        let defaultLanguage = preference!.stringForKey("default-language")
        let loginBySession = preference!.boolForKey("login-by-session")
        defaultLanguageSegmentedControl.selectedSegmentIndex = (defaultLanguage != nil ? (defaultLanguage == "en" ? 0 : 1) : (String(sysDefaultLanguage) == "en" ? 0 : 1))
        loginBySessionSwitch.setOn(loginBySession, animated: true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func openSocialPage(url: String) {

    }

}
