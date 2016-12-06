//
//  AboutUsTableViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class AboutUsTableViewController: UITableViewController {
    
    @IBOutlet var aboutTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var sectionTitleArray : NSMutableArray = NSMutableArray()
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool : NSMutableArray = NSMutableArray()
    
    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var about = [Int: [String: String]]()
    var selectedRow = 0
    var aboutIds: [Int] = [Int]()
    var aboutIndex: Int = 0
    let controller = "about"
    let cellIdentifier = "aboutBox"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "AboutUsTableViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("aboutQMotor")
        
        aboutTableView.estimatedRowHeight = 44.0
        aboutTableView.rowHeight = UITableViewAutomaticDimension
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        arrayForBool = ["1","0","0","0"]
        let activity: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activity.center = CGPoint(x: CGFloat(Utility.ScreenSize.SCREEN_WIDTH), y: CGFloat(Utility.ScreenSize.SCREEN_HEIGHT))
        activity.startAnimating()
        self.view.addSubview(activity)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.utility.isConnectedToNetwork() {
            getOnlineAbout()
        } else {
            getOfflineAbout()
        }
    }
    
    func getOfflineAbout() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.about = self.worker.select(Worker.Entities.ABOUT, whereCondition: nil, sortBy: "id", isAscending: false, cursor: 1, limit: 100, indexedBy: "index")!
            dispatch_async(dispatch_get_main_queue()) {
                self.aboutTableView?.reloadData()
            }
        }
    }
    
    func getOnlineAbout() {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=all&sortId=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let trimsList = resultset?.dictionaryValue[self.controller] {
                    for (_, trim) in trimsList {
                        var record = [String: String]()
                        for (key, value) in trim {
                            record[key] = value.stringValue
                        }
                        if self.aboutIds.contains(Int(record["id"]!)!) == false {
                            self.about[self.aboutIndex] = record
                            self.aboutIndex = self.aboutIndex + 1
                            self.aboutIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.aboutTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.aboutTableView?.reloadData()
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.about.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if arrayForBool.objectAtIndex(section).boolValue == true {
            return 1
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if arrayForBool.objectAtIndex(indexPath.section).boolValue == true {
            return 200
        }
        return 2;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.tag = section
        headerView.backgroundColor = utility.colorFromRGB(0xf6f6f6)
        let headerString = UILabel(frame: CGRect(x: 20, y: 10.0, width: tableView.frame.size.width-40, height: 17.0))
        headerString.font = UIFont(name: headerString.font.fontName, size: 14)
        if let record = self.about[section] {
            headerString.text = record["title_name_"+appDefaultLanguage!]!
        }
        headerView.addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(AboutUsTableViewController.sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(headerTapped)
        
        let border = UIView(frame: CGRectMake(0, 39, self.view.bounds.width,1))
        border.backgroundColor = utility.colorFromRGB(0xdedede)
        headerView.addSubview(border)
        
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if indexPath.row == 0 {
            var collapsed = arrayForBool.objectAtIndex(indexPath.section).boolValue
            collapsed = !collapsed;
            arrayForBool.replaceObjectAtIndex(indexPath.section, withObject: collapsed)
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell:AboutTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! AboutTableViewCell
        if self.about.count > 0 {
            if let record = self.about[indexPath.section] {
                cell.title.text = record["sub_name_"+appDefaultLanguage!]
                
                var subject : String = String();
                
                subject = record["desc_name_"+appDefaultLanguage!]!

                subject = subject.stringByReplacingOccurrencesOfString("&#39;", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil);
                
                subject = subject.stringByReplacingOccurrencesOfString("&nbsp;", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil);


                cell.subject.text = subject             }
        }
        return cell
    }
    
}

