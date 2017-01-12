//
//  CarDealersViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class CarDealersViewController: UIViewController {
    
    @IBOutlet weak var sortDealersByLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var dealersCollectionView: UICollectionView!
    @IBOutlet weak var sortBy: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "dealers"
    var reuseIdentifier = "dealerBox"
    var carDealers = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 10
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var dealersIds: [Int] = [Int]()
    var dealerIndex: Int = 0
    var sortCntCars = "desc"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "CarDealersViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("carDealersTitle")
        sortBy.setTitle(utility.__("highestButton"), forState: UIControlState.Normal)
        sortDealersByLabel.text = utility.__("sortDealersByLabel")
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(CarDealersViewController.getOnlineDealers as (CarDealersViewController) -> () -> ()), forControlEvents: UIControlEvents.ValueChanged)
        dealersCollectionView!.addSubview(refreshControl)
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        self.dealersCollectionView.hidden = true
        self.activityIndicator.hidden = false
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineDealers("highest")
        } else {
            getOfflineDealers()
        }
        hasMore = true
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
    }
    
    func getOnlineDealers() {
        getOnlineDealers(self.sortCntCars == "desc" ? "highest" : "lowest")
    }
    
    func getOnlineDealers(sortBy: String = "highest") {
        self.carDealers = [:]
        self.dealersIds = []
        self.dealerIndex = 0
        self.nextCursor = 1
        self.hasMore = true
        if sortBy == "highest" {
            self.sortCntCars = "desc"
        } else {
            self.sortCntCars = "asc"
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=\(self.controller)&sortCntCars=desc&page=1&rowCount=\(self.limit)&sortCntCars=\(self.sortCntCars)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            record[key] = value.stringValue
                        }
                        if self.dealersIds.contains(Int(record["id"]!)!) == false {
                            self.carDealers[self.dealerIndex] = record
                            self.dealerIndex = self.dealerIndex + 1
                            self.dealersIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.dealersCollectionView.hidden = false
                    self.activityIndicator.hidden = true
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.hidden = true
                    self.dealersCollectionView.hidden = false
                    self.dealersCollectionView?.reloadData()
                }
            }
        }
    }
    
    func getOfflineDealers() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.carDealers = self.worker.select(Worker.Entities.DEALERS, whereCondition: nil, sortBy: "id", cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.hidden = true
                self.dealersCollectionView.hidden = false
                self.dealersCollectionView?.reloadData()
            }
        }
    }
    
    @IBAction func sortBy(sender: UIButton) {
        self.dealersCollectionView.hidden = true
        self.activityIndicator.hidden = false
        self.nextCursor = 1
        if sortCntCars == "desc" {
            sortBy.setTitle(utility.__("lowestButton"), forState: UIControlState.Normal)
            getOnlineDealers("lowest")
        } else {
            getOnlineDealers("highest")
            sortBy.setTitle(utility.__("highestButton"), forState: UIControlState.Normal)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.carDealers.count > 0 ? self.carDealers.count : 6
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
        cellHeight = CGFloat(150)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CarDealersCollectionViewCell
        if self.carDealers.count > 0 {
            if let record = self.carDealers[indexPath.row] {
                
                cell.carCounts.text = record["cntCars"]
                cell.carDealerPhone.text = record["phone"]
                cell.dealerName.text = record["agent_name_"+appDefaultLanguage!]?.uppercaseString
                cell.carsAvailableLabel.text = utility.__("dealerCarsAvailableLabel")
                
//                if cell.tag <= 0 {
//                    cell.tag = Int(record["id"]!)!
//                    let gradientLayer = CAGradientLayer()
//                    gradientLayer.frame = cell.backgroundGradient.bounds
//                    gradientLayer.colors = [color3, color2, color1]
//                    gradientLayer.locations = [0.0, 0.5, 1.0]
//                    cell.backgroundGradient.layer.addSublayer(gradientLayer)
//                }
                
                if let featuredImage = record["header"] {
                    var featuredImage = featuredImage.stringByReplacingOccurrencesOfString("mobile/", withString: "")
                    featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    if let imageUrl = NSURL(string: featuredImage) {
                        cell.carHeader.hnk_setImageFromURL(imageUrl)
                    }
                }
            }
        }
        return cell
    }
    
    var footerCell: LoadMoreCollectionReusableView!
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "loadMore", forIndexPath: indexPath) as! LoadMoreCollectionReusableView
        footerCell = cell
        footerCell.loadMoreActivityIndicator.hidden = false
        footerCell.theEndlabel.text = utility.__("theEndLabel")
        footerCell.theEndlabel.hidden = true
        return cell
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
                        self.worker.makeUrl("\(self.controller)?act=\(self.controller)&sortCntCars=desc&page=\(self.nextCursor)&rowCount=\(self.limit)&sortCntCars=\(self.sortCntCars)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let carsList = resultset?.dictionaryValue[self.controller] {
                                for (_, car) in carsList {
                                    var record = [String: String]()
                                    for (key, value) in car {
                                        record[key] = value.stringValue
                                    }
                                    if self.dealersIds.contains(Int(record["id"]!)!) == false {
                                        self.carDealers[self.dealerIndex] = record
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
                                self.dealersCollectionView?.reloadData()
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newDealers = self.worker.select(Worker.Entities.DEALERS, whereCondition: nil, sortBy: "id", cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newDealers!.count > 0 {
                            for (id, record) in newDealers! {
                                self.carDealers[id + self.carDealers.count] = record
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isReady = true
                            self.nextCursor += 1
                            self.refreshControl.hidden = false
                            self.refreshControl.endRefreshing()
                            self.dealersCollectionView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewDealersCars" {
            let index = self.dealersCollectionView.indexPathForCell(sender as! UICollectionViewCell)?.row
            if let dealer = self.carDealers[index!] {
                if let dealerID = dealer["id"] {
                    let dealerView = segue.destinationViewController as! DealerCarsViewController
                    dealerView.dealerId = Int(dealerID)!
                }
            }
        }
    }
    
}
