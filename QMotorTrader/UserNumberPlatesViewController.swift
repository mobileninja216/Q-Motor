//
//  UserNumberPlatesViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class UserNumberPlatesViewController: UIViewController {
    
    @IBOutlet weak var numberPlatesCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
    var profileId: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "UserNumberPlatesViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = utility.__("userNumberPlatesTitle")
        refreshControl.addTarget(self, action: #selector(UserNumberPlatesViewController.getOnlineNumberPlates), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        numberPlatesCollectionView!.addSubview(refreshControl)
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        self.numberPlatesCollectionView.hidden = true
        self.activityIndicator.hidden = false
        if let profileId = Int(profile["id"]!) {
            self.profileId = abs(profileId)
        }
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nextCursor = 1
        getOnlineNumberPlates()
        hasMore = true
    }
    
    func getOnlineNumberPlates() {
        self.numberPlates = [:]
        self.dealersIds = []
        self.dealerIndex = 0
        self.nextCursor = 1
        self.hasMore = true
        self.refreshControl.hidden = false
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=\(self.controller)&page=1&rowCount=\(self.limit)&searchPhrase={\"user_id|=\":\(self.profileId)}").requestAndSave(Worker.Method.GET, parameters: [:]) {
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberPlates.count > 0 ? self.numberPlates.count : 0
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UserNumberPlatesCollectionViewCell
        if self.numberPlates.count > 0 {
            if let record = self.numberPlates[indexPath.row] {
                cell.platePrice.text = record["price"]! + " " + utility.__("qar")
                cell.plateNumber.text = record["number_plates"]
                cell.deleteButton.tag = Int(record["id"]!)!
            }
        }
        return cell
    }
    
    var footerCell: LoadMoreCollectionReusableView!
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerNumberPlates", forIndexPath: indexPath) as! NumberPlatesHeaderCollectionReusableView
            cell.numberPlatesInQMTLabel.text = utility.__("userNumberPlatesLabel")
            return cell
        } else {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "loadMore", forIndexPath: indexPath) as! LoadMoreCollectionReusableView
            footerCell = cell
            footerCell.loadMoreActivityIndicator.hidden = false
            footerCell.theEndlabel.hidden = true
            return cell
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if hasMore == false {
            footerCell.loadMoreActivityIndicator.hidden = true
            footerCell.theEndlabel.hidden = false
        }
        if hasMore && isReady {
            if offsetY > contentHeight - scrollView.frame.size.height {
                self.isReady = false
                if utility.isConnectedToNetwork() {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        self.worker.makeUrl("\(self.controller)?act=\(self.controller)&page=\(self.nextCursor)&rowCount=\(self.limit)&searchPhrase={\"user_id|=\":\(self.profileId)}").requestAndSave(Worker.Method.GET, parameters: [:]) {
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
                }
            }
        }
    }
    
    @IBAction func deletePlate(sender: UIButton) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        let plateId = sender.tag
        let view = sender.superview!
        let cell = view.superview?.superview as! UserNumberPlatesCollectionViewCell
        let indexPath = numberPlatesCollectionView.indexPathForCell(cell)
        cell.deleteActivityIndicator.hidden = false
        cell.deleteButton.hidden = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)/\(plateId)").request(Worker.Method.DELETE, parameters: [:]) {
                (resultset, pagination, messageError) in
                if let error = messageError {
                    if let statusCode = Int(error["code"]!) {
                        if statusCode == 200 {
                            self.numberPlates[indexPath!.row] = nil
                        } else {
                            self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.getOnlineNumberPlates()
                }
            }
        }
    }
}
