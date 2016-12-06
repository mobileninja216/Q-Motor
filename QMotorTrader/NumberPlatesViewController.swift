//
//  NumberPlatesViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class NumberPlatesViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var plateImage: UIImageView!
    @IBOutlet weak var numberPlatesCollectionView: UICollectionView!
    @IBOutlet weak var sortBy: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "plates"
    var reuseIdentifier = "numberPlateBox"
    var numberPlates = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var dealersIds: [Int] = [Int]()
    var dealerIndex: Int = 0
    var totalPlates: Int = 0
    var sortPrice = "desc"
    var numberPlateId: Int = 0
    var searchPhrase = ""
    var isBack: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "NumberPlatesViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = utility.__("numberPlatesTitle")
        refreshControl.addTarget(self, action: #selector(NumberPlatesViewController.getOnlineNumberPlates as (NumberPlatesViewController) -> () -> ()), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        numberPlatesCollectionView!.addSubview(refreshControl)
        if self.revealViewController() != nil {
            utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
            isBack = false
        } else {
            isBack = true
            menuButton.image = UIImage(named: "back")
        }
    }
    
    @IBAction func dismissView(sender: UIBarButtonItem) {
        if isBack {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        self.numberPlatesCollectionView.hidden = true
        self.activityIndicator.hidden = false
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineNumberPlates("highest")
        } else {
            getOfflineNumberPlates()
        }
        hasMore = true
    }
    
    func getOnlineNumberPlates() {
        getOnlineNumberPlates(self.sortPrice == "desc" ? "highest" : "lowest")
    }
    
    func getOnlineNumberPlates(sortBy: String = "highest") {
        self.numberPlates = [:]
        self.dealersIds = []
        self.dealerIndex = 0
        self.nextCursor = 1
        self.hasMore = true
        if sortBy == "highest" {
            self.sortPrice = "desc"
        } else {
            self.sortPrice = "asc"
        }
        self.refreshControl.hidden = false
        self.refreshControl.beginRefreshing()
        if numberPlateId > 0 {
            searchPhrase = "&searchPhrase={\"number_plates|like\":\"%"+String(numberPlateId)+"%\"}"
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=\(self.controller)&page=1&rowCount=\(self.limit)&sortPrice=\(self.sortPrice)\(self.searchPhrase)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.totalPlates = pagination!["total"].intValue
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            record[key] = value.stringValue
                        }
                        if self.dealersIds.contains(Int(record["id"]!)!) == false {
                            self.numberPlates[self.dealerIndex] = record
                            self.dealerIndex = self.dealerIndex + 1
                            self.dealersIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.numberPlatesCollectionView.hidden = false
                    self.activityIndicator.hidden = true
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.hidden = true
                    self.numberPlatesCollectionView.hidden = false
                    self.numberPlatesCollectionView?.reloadData()
                }
            }
        }
    }
    
    func getOfflineNumberPlates(sortBy: String = "highest") {
        var isAscending = true
        if sortBy == "highest" {
            isAscending = false
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.numberPlates = self.worker.select(Worker.Entities.PLATES, whereCondition: nil, sortBy: "id", isAscending: isAscending, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.nextCursor = 2
                self.activityIndicator.hidden = true
                self.numberPlatesCollectionView.hidden = false
                self.numberPlatesCollectionView?.reloadData()
            }
        }
    }
    
    @IBAction func sortBy(sender: UIButton) {
        self.numberPlatesCollectionView.hidden = true
        self.activityIndicator.hidden = false
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            if self.sortPrice == "desc" {
                sortBy.setTitle(utility.__("lowest"), forState: UIControlState.Normal)
                getOnlineNumberPlates("lowest")
            } else {
                getOnlineNumberPlates("highest")
                sortBy.setTitle(utility.__("highest"), forState: UIControlState.Normal)
            }
        } else {
            if self.sortPrice == "desc" {
                sortBy.setTitle(utility.__("lowest"), forState: UIControlState.Normal)
                getOfflineNumberPlates("lowest")
            } else {
                getOfflineNumberPlates("highest")
                sortBy.setTitle(utility.__("highest"), forState: UIControlState.Normal)
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberPlates.count > 0 ? self.numberPlates.count : 6
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    var cellWidth: CGFloat = CGFloat(100)
    var cellHeight: CGFloat = CGFloat(80)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(collectionView.bounds)
        var columns = 1
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            columns = 1
        } else {
            columns = 2
        }
        let paddingCount = CGFloat(columns) + 1
        let cellPadding = 10
        let widthWithoutPadding = width - (CGFloat(cellPadding) * paddingCount)
        cellWidth = widthWithoutPadding / CGFloat(columns)
        cellHeight = CGFloat(142)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NumberPlatesCollectionViewCell
        if self.numberPlates.count > 0 {
            if let record = self.numberPlates[indexPath.row] {
                cell.numberPrice.text = utility.getFormattedStringFromNumber(Double(record["price"]!)!) + " " + utility.__("qar")
                cell.carNumber.text = record["number_plates"]
                cell.ownerPhoneNumber.text = record["phone"]
                cell.callSellerNowLabel.text = utility.__("callSellerNowLabel")
            }
        }
        return cell
    }
    
    var footerCell: LoadMoreCollectionReusableView!
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerNumberPlates", forIndexPath: indexPath) as! NumberPlatesHeaderCollectionReusableView
            cell.numberPlatesAvailable.text = "\(self.totalPlates) \(utility.__("platesAvailable"))"
            cell.numberPlatesInQMTLabel.text = utility.__("numberPlatesInQMTLabel")
            return cell
        } else {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "loadMore", forIndexPath: indexPath) as! LoadMoreCollectionReusableView
            footerCell = cell
            footerCell.loadMoreActivityIndicator.hidden = false
            footerCell.theEndlabel.text = utility.__("done")
            footerCell.theEndlabel.hidden = true
            return cell
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if hasMore == false && footerCell != nil {
            footerCell.loadMoreActivityIndicator.hidden = true
            footerCell.theEndlabel.hidden = false
        }
        if hasMore && isReady {
            if offsetY > contentHeight - scrollView.frame.size.height {
                self.isReady = false
                if utility.isConnectedToNetwork() {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        self.worker.makeUrl("\(self.controller)?act=\(self.controller)&page=\(self.nextCursor)&rowCount=\(self.limit)&sortPrice=\(self.sortPrice)\(self.searchPhrase)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let carsList = resultset?.dictionaryValue[self.controller] {
                                for (_, car) in carsList {
                                    var record = [String: String]()
                                    for (key, value) in car {
                                        record[key] = value.stringValue
                                    }
                                    if self.dealersIds.contains(Int(record["id"]!)!) == false {
                                        self.numberPlates[self.dealerIndex] = record
                                        self.dealerIndex = self.dealerIndex + 1
                                        self.dealersIds.append(Int(record["id"]!)!)
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isReady = true
                                self.hasMore = pagination!["hasMore"].boolValue
                                self.nextCursor = pagination!["page"].intValue
                                self.nextCursor += 1
                                self.refreshControl.hidden = false
                                self.refreshControl.endRefreshing()
                                self.numberPlatesCollectionView?.reloadData()
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newDealers = self.worker.select(Worker.Entities.PLATES, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newDealers!.count > 0 {
                            for (id, record) in newDealers! {
                                self.numberPlates[id + self.numberPlates.count] = record
                            }
                        } else {
                            self.hasMore = false
                            self.isReady = false
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isReady = true
                            self.nextCursor = self.nextCursor + 1
                            self.refreshControl.hidden = false
                            self.refreshControl.endRefreshing()
                            self.numberPlatesCollectionView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewDealersCars" {
            let selectedIndex = self.numberPlatesCollectionView!.indexPathForCell(sender as! UICollectionViewCell)
            if let row = selectedIndex?.row {
                let navigationController = segue.destinationViewController as! UINavigationController
                let dealerView = navigationController.viewControllers.first as! DealerCarsViewController
                if let dealer = self.numberPlates[row] {
                    let dealerId = Int(dealer["id"]!)
                    dealerView.dealerId = dealerId!
                }
            }
        }
    }
    
}
