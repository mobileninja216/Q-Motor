//
//  MakeViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/1/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MakeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var makeTableView: UITableView!
    var footerView: UIView!
    
    var refreshControl = UIRefreshControl()
    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var makes = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var controller = "make"
    var hasMore: Bool = false
    var isReady: Bool = true
    var selectedRow = -1
    var makesIds: [Int] = [Int]()
    var makeIndex: Int = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "FilterViewController"
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
        makeTableView.delegate = self
        makeTableView?.dataSource = self
        self.makeTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(MakeViewController.getOnlineMake), forControlEvents: UIControlEvents.ValueChanged)
        self.navigationItem.title = utility.__("makeTitle")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineMake()
        } else {
            getOfflineMake()
        }
        hasMore = true
    }
    
    func getOfflineMake() {
        self.refreshControl.hidden = true
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.makes = self.worker.select(Worker.Entities.MAKE, whereCondition: nil, sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.makeTableView!.hidden = false
                self.refreshControl.endRefreshing()
                self.makeTableView?.reloadData()
            }
        }
    }
    
    func getOnlineMake() {
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
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortMake_name_\(appDefaultLanguage!)=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let makesList = resultset?.dictionaryValue[self.controller] {
                    for (_, make) in makesList {
                        var record = [String: String]()
                        for (key, value) in make {
                            record[key] = value.stringValue
                        }
                        if self.makesIds.contains(Int(record["id"]!)!) == false {
                            self.makes[self.makeIndex] = record
                            self.makeIndex = self.makeIndex + 1
                            self.makesIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.refreshControl.hidden = false
                    self.activityIndicator.hidden = true
                    self.makeTableView.hidden = false
                    self.refreshControl.endRefreshing()
                    self.makeTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.makeTableView?.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return makes.count > 0 ? makes.count : 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("makeBox", forIndexPath: indexPath) as! MakeTableViewCell
        if self.makes.count > 0 {
            if let record = self.makes[indexPath.row] {
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
                cell.makeName.text = record["make_name_"+appDefaultLanguage!]
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
                        self.worker.makeUrl("filter?act=make&rowCount=\(self.limit)&page=\(self.nextCursor)&sortMake_name_\(appDefaultLanguage!)=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let makesList = resultset?.dictionaryValue[self.controller] {
                                for (_, make) in makesList {
                                    var record = [String: String]()
                                    for (key, value) in make {
                                        record[key] = value.stringValue
                                    }
                                    if self.makesIds.contains(Int(record["id"]!)!) == false {
                                        self.makes[self.makeIndex] = record
                                        self.makeIndex = self.makeIndex + 1
                                        self.makesIds.append(Int(record["id"]!)!)
                                    }                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isReady = true
                                self.hasMore = pagination!["hasMore"].boolValue
                                self.nextCursor = pagination!["page"].intValue
                                self.nextCursor += 1
                                self.footerView.hidden = true
                                self.makeTableView?.reloadData()
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newMakes = self.worker.select(Worker.Entities.MAKE, whereCondition: nil, sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newMakes!.count > 0 {
                            for (id, record) in newMakes! {
                                self.makes[id + self.makes.count] = record
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isReady = true
                            self.nextCursor += 1
                            self.refreshControl.hidden = false
                            self.refreshControl.endRefreshing()
                            self.makeTableView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        if let make = makes[indexPath.row] {
            if let makeID = make["id"] {
                if (filterArray["make_id"] != nil && Int(filterArray["make_id"]!) != Int(makeID)) {
                    filterArray["model_id"] = nil
                    filterArray["model_name"] = nil
                    filterArray["trim_id"] = nil
                    filterArray["trim_name"] = nil
                }
                filterArray["make_id"] = makeID
                filterArray["make_name"] = make["make_name_"+appDefaultLanguage!]!
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        self.selectedRow = -1
        filterArray["make_id"] = nil
        filterArray["make_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
    
}
