//
//  SavedAdvertsViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class SavedAdvertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var controlItemLabel: UILabel!
    @IBOutlet weak var savedCarsLabel: UILabel!
    @IBOutlet weak var resultsNumber: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carsTableView: UITableView!
    var footerView: UIView!

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "cars"
    var cars = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var carsIds: [Int] = [Int]()
    var carIndex: Int = 0
    var selectedCarId: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SavedAdvertsViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedCarsLabel.text = utility.__("savedCarsLabel")
        controlItemLabel.text = utility.__("controlItemLabel")
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        refreshControl.tintColor = UIColor.lightGrayColor()
        refreshControl.addTarget(self, action: #selector(SavedAdvertsViewController.getOnlineCars as (SavedAdvertsViewController) -> () -> ()), forControlEvents: UIControlEvents.ValueChanged)
        carsTableView!.addSubview(refreshControl)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.utility.isConnectedToNetwork() {
            getOnlineCars(true)
        }
    }
    
    func getOnlineCars() {
        getOnlineCars(false)
    }
    
    func getOnlineCars(haveRefreshControl: Bool) {
        self.cars = [:]
        self.self.carsIds = []
        self.carIndex = 0
        self.nextCursor = 1
        self.hasMore = true
        if haveRefreshControl {
            self.activityIndicator.hidden = false
        }
        let fullUrl = "adverts?act=adverts&ch=none&page=\(self.nextCursor)&rowCount=\(self.limit)"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl(fullUrl).requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                let totalCars = pagination?.dictionary!["total"]!.stringValue
                self.resultsNumber.text = "(" + totalCars! + ")"
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            record[key] = value.stringValue
                        }
                        if self.carsIds.contains(Int(record["id"]!)!) == false {
                            self.cars[self.carIndex] = record
                            self.carIndex = self.carIndex + 1
                            self.carsIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    if haveRefreshControl {
                        self.activityIndicator.hidden = true
                    } else {
                        self.refreshControl.hidden = false
                        self.refreshControl.endRefreshing()
                    }
                    self.carsTableView?.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count > 0 ? cars.count+1 : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("bodyBox", forIndexPath: indexPath) as! MyAdvertsTableViewCell
            if cell.isEqual(nil) == false {
                if self.cars.count > 0 {
                    if let record = self.cars[indexPath.row-1] {
                        cell.carMakeAndModel.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + " " + record["year_"+appDefaultLanguage!]!
                        cell.advertId.text = record["id"]!
                        cell.datetime.text = record["updated_at"]!
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("headerBox", forIndexPath: indexPath) as! AdvertsHeaderTableViewCell
            cell.advertsIDLabel.text = utility.__("advertsIDLabel")
            cell.makeModelLabel.text = utility.__("makeModelLabel")
            cell.advertsLatestUpdateLabel.text = utility.__("advertsLatestUpdateLabel")
            return cell
        }
    }
    
    var selectedIndexPath: NSIndexPath!
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.cars.count > 0 {
            if indexPath.row > 0 {
                let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
                cell.contentView.backgroundColor = utility.colorFromRGB(0xdedede)
                if let record = self.cars[indexPath.row-1] {
                    self.selectedIndexPath = indexPath
                    self.selectedCarId = Int(record["id"]!)!
                    self.editButton.hidden = false
                    self.deleteButton.hidden = false
                }
            }
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.contentView.backgroundColor = UIColor.whiteColor()
        selectedIndexPath = nil
        self.selectedCarId = 0
        self.editButton.hidden = true
        self.deleteButton.hidden = true
    }
    
    @IBAction func deleteAdvert(sender: UIButton) {
        let currentPath = self.selectedIndexPath.row - 1
        if currentPath >= 0 &&  self.selectedCarId > 0 {
            self.deleteActivityIndicator.hidden = false
            self.deleteButton.hidden = true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("adverts/\(self.selectedCarId)").request(Worker.Method.DELETE, parameters: [:]) {
                    (resultset, pagination, messageError) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let _ = messageError {
                            self.getOnlineCars(true)
                        }
                        self.deleteActivityIndicator.hidden = true
                        self.deleteButton.hidden = false
                    }
                }
            }
        }
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
                        self.worker.makeUrl("adverts?act=adverts&ch=none&page=\(self.nextCursor)&rowCount=\(self.limit)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let carsList = resultset?.dictionaryValue[self.controller] {
                                for (_, car) in carsList {
                                    var record = [String: String]()
                                    for (key, value) in car {
                                        record[key] = value.stringValue
                                    }
                                    if self.carsIds.contains(Int(record["id"]!)!) == false {
                                        self.cars[self.carIndex] = record
                                        self.carIndex = self.carIndex + 1
                                        self.carsIds.append(Int(record["id"]!)!)
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isReady = true
                                self.hasMore = pagination!["hasMore"].boolValue
                                self.nextCursor = pagination!["page"].intValue
                                self.nextCursor += 1
                                self.footerView.hidden = true
                                self.carsTableView?.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editAdvert" {
            let sellMyCarViewController = segue.destinationViewController as! SellMyCarViewController
            sellMyCarViewController.selectedAdvertId = selectedCarId
        }
    }
}
