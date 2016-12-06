//
//  TrimViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 9/2/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class TrimViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var trimTableView: UITableView!
    var refreshControl = UIRefreshControl()
    var footerView: UIView!

    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var trims = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var selectedRow = -1
    var makeId: String = filterArray["make_id"]!
    var modelId: String = filterArray["model_id"]!
    var trimsIds: [Int] = [Int]()
    var trimIndex: Int = 0
    let controller = "trim"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "TrimViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inintiateUi()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
    }
    
    func inintiateUi() {
        trimTableView.delegate = self
        trimTableView?.dataSource = self
        trimTableView.insertSubview(refreshControl, atIndex: 0)
        refreshControl.addTarget(self, action: #selector(TrimViewController.getOnlineTrim), forControlEvents: UIControlEvents.ValueChanged)
        
        self.navigationItem.title = utility.__("trimTitle")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineTrim()
        } else {
            getOfflineTrim()
        }
        hasMore = true
    }
    
    func getOfflineTrim() {
        self.refreshControl.hidden = true
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.trims = self.worker.select(Worker.Entities.TRIM, whereCondition: "make_id=\(self.makeId) AND model_id=\(self.modelId)", sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.trimTableView!.hidden = false
                self.refreshControl.endRefreshing()
                self.trimTableView?.reloadData()
            }
        }
    }
    
    func getOnlineTrim() {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            self.refreshControl.endRefreshing()
            self.refreshControl.hidden = false
            return
        }
        self.nextCursor = 1
        self.refreshControl.hidden = true
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortTrim_name_\(appDefaultLanguage!)=asc&searchPhrase={\"make_id|=\":\"\(self.makeId)\",\"model_id|=\":\"\(self.modelId)\"}").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let trimsList = resultset?.dictionaryValue[self.controller] {
                    for (_, trim) in trimsList {
                        var record = [String: String]()
                        for (key, value) in trim {
                            record[key] = value.stringValue
                        }
                        if self.trimsIds.contains(Int(record["id"]!)!) == false {
                            self.trims[self.trimIndex] = record
                            self.trimIndex = self.trimIndex + 1
                            self.trimsIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.trimTableView.hidden = false
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.trimTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.trimTableView?.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trims.count > 0 ? trims.count : 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trimBox", forIndexPath: indexPath) as! TrimTableViewCell
        if self.trims.count > 0 {
            if let record = self.trims[indexPath.row] {
                if self.selectedRow > -1 {
                    if self.selectedRow == indexPath.row {
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        cell.highlighted = true
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.None
                        cell.highlighted = false
                    }
                } else {
                    if filterArray["make_id"] != nil && filterArray["make_id"] == record["id"] {
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        cell.highlighted = true
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.None
                        cell.highlighted = false
                    }
                }
                cell.trimName.text = record["trim_name_"+appDefaultLanguage!]
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.startAnimating()
        footerView.hidden = true
        let activityIndicatorHeight: CGFloat = CGFloat(24)
        let activityIndicatorWidth: CGFloat = CGFloat(24)
        let footerViewWidth: CGFloat = CGFloat(tableView.frame.size.width)
        activityIndicator.frame = CGRectMake(((footerViewWidth/2.0) - (activityIndicatorWidth/2.0)), (activityIndicatorHeight/2.0), activityIndicatorWidth, activityIndicatorHeight)
        footerView.addSubview(activityIndicator)
        return footerView
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if hasMore && isReady {
            if offsetY > contentHeight - scrollView.frame.size.height {
                footerView.hidden = false
                self.isReady = false
                if utility.isConnectedToNetwork() {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=\(self.nextCursor)&sortTrim_name_\(appDefaultLanguage!)=asc&searchPhrase={\"make_id|=\":\"\(self.makeId)\",\"model_id|=\":\"\(self.modelId)\"}").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let modelsList = resultset?.dictionaryValue[self.controller] {
                                for (_, model) in modelsList {
                                    var record = [String: String]()
                                    for (key, value) in model {
                                        record[key] = value.stringValue
                                    }
                                    if self.trimsIds.contains(Int(record["id"]!)!) == false {
                                        self.trims[self.trimIndex] = record
                                        self.trimIndex = self.trimIndex + 1
                                        self.trimsIds.append(Int(record["id"]!)!)
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isReady = true
                                self.hasMore = pagination!["hasMore"].boolValue
                                self.nextCursor = pagination!["page"].intValue
                                self.nextCursor += 1
                                self.footerView.hidden = true
                                self.trimTableView?.reloadData()
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newTrims = self.worker.select(Worker.Entities.MAKE, whereCondition: "make_id=\(self.makeId) AND model_id=\(self.modelId)", sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newTrims!.count > 0 {
                            for (id, record) in newTrims! {
                                self.trims[id + self.trims.count] = record
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isReady = true
                            self.nextCursor += 1
                            self.refreshControl.hidden = false
                            self.refreshControl.endRefreshing()
                            self.trimTableView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        if let trim = trims[indexPath.row] {
            if let trimID = trim["id"] {
                filterArray["trim_id"] = trimID
                filterArray["trim_name"] = trim["trim_name_"+appDefaultLanguage!]!
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        self.selectedRow = -1
        filterArray["trim_id"] = nil
        filterArray["trim_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
    
}
