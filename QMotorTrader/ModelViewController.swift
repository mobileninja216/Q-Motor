//
//  ModelViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/1/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class ModelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var modelTableView: UITableView!
    var refreshControl = UIRefreshControl()
    var footerView: UIView!

    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var models = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var selectedRow = -1
    var makeId: String = filterArray["make_id"]!
    var modelsIds: [Int] = [Int]()
    var modelIndex: Int = 0
    let controller = "model"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "ModelViewController"
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
        modelTableView.delegate = self
        modelTableView?.dataSource = self
        modelTableView.insertSubview(refreshControl, atIndex: 0)
        refreshControl.addTarget(self, action: #selector(ModelViewController.getOnlineModel), forControlEvents: UIControlEvents.ValueChanged)
        
        self.navigationItem.title = utility.__("modelTitle")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineModel()
        } else {
            getOfflineModel()
        }
        hasMore = true
    }
    
    func getOfflineModel() {
        self.refreshControl.hidden = true
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.models = self.worker.select(Worker.Entities.MODEL, whereCondition: "make_id=\(self.makeId)", sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.modelTableView!.hidden = false
                self.refreshControl.endRefreshing()
                self.modelTableView?.reloadData()
            }
        }
    }
    
    func getOnlineModel() {
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
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortModel_name_\(appDefaultLanguage!)=asc&searchPhrase={\"make_id|=\":\"\(self.makeId)\"}").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let modelsList = resultset?.dictionaryValue[self.controller] {
                    for (_, model) in modelsList {
                        var record = [String: String]()
                        for (key, value) in model {
                            record[key] = value.stringValue
                        }
                        if self.modelsIds.contains(Int(record["id"]!)!) == false {
                            self.models[self.modelIndex] = record
                            self.modelIndex = self.modelIndex + 1
                            self.modelsIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.modelTableView.hidden = false
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.modelTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.modelTableView?.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count > 0 ? models.count : 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("modelBox", forIndexPath: indexPath) as! ModelTableViewCell
        if self.models.count > 0 {
            if let record = self.models[indexPath.row] {
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
                cell.modelName.text = record["model_name_"+appDefaultLanguage!]
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
                        self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=\(self.nextCursor)&sortModel_name_\(appDefaultLanguage!)=asc&searchPhrase={\"make_id|=\":\"\(self.makeId)\"}").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let modelsList = resultset?.dictionaryValue[self.controller] {
                                for (_, model) in modelsList {
                                    var record = [String: String]()
                                    for (key, value) in model {
                                        record[key] = value.stringValue
                                    }
                                    if self.modelsIds.contains(Int(record["id"]!)!) == false {
                                        self.models[self.modelIndex] = record
                                        self.modelIndex = self.modelIndex + 1
                                        self.modelsIds.append(Int(record["id"]!)!)
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isReady = true
                                self.hasMore = pagination!["hasMore"].boolValue
                                self.nextCursor = pagination!["page"].intValue
                                self.nextCursor += 1
                                self.footerView.hidden = true
                                self.modelTableView?.reloadData()
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newModels = self.worker.select(Worker.Entities.MAKE, whereCondition: "make_id=\(self.makeId)", sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newModels!.count > 0 {
                            for (id, record) in newModels! {
                                self.models[id + self.models.count] = record
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isReady = true
                            self.nextCursor = self.nextCursor + 1
                            self.refreshControl.hidden = false
                            self.refreshControl.endRefreshing()
                            self.modelTableView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        if let model = models[indexPath.row] {
            if let modelID = model["id"] {
                if (filterArray["model_id"] != nil && Int(filterArray["model_id"]!) != Int(modelID)) {
                    filterArray["trim_id"] = nil
                    filterArray["trim_name"] = nil
                }
                filterArray["model_id"] = modelID
                filterArray["model_name"] = model["model_name_"+appDefaultLanguage!]!
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        self.selectedRow = -1
        filterArray["model_id"] = nil
        filterArray["model_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
    
}
