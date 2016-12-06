//
//  MyGarrageViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyGarrageViewController: UIViewController {
    
    @IBOutlet weak var myGarageLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var carCount: UILabel!
    @IBOutlet weak var garageCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "garage"
    var reuseIdentifier = "garageBox"
    var garage = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var garageIds: [Int] = [Int]()
    var garageIndex: Int = 0
    var totalPlates: Int = 0
    var isLoading: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MyGarrageViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = utility.__("myGarageTitle")
        myGarageLabel.text = utility.__("myGarageTitle")
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        refreshControl.addTarget(self, action: #selector(MyGarrageViewController.getOnlineGarage), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        garageCollectionView!.addSubview(refreshControl)
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        self.garageCollectionView.hidden = true
        self.activityIndicator.hidden = false
        self.nextCursor = 1
        self.getOnlineGarage()
    }
    
    func getOnlineGarage() {
        self.garage = [:]
        self.garageIds = []
        self.garageIndex = 0
        self.nextCursor = 1
        self.hasMore = true
        self.refreshControl.hidden = false
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=all&page=1&rowCount=\(self.limit)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.carCount.text = "(\(pagination!["total"].stringValue))"
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            if key == "cars_image" {
                                record["featuredImage"] = value[0]["image"].stringValue
                                for (_, carImage) in value {
                                    if carImage["primary_photo"].int == 1 {
                                        record["featuredImage"] = carImage["image"].stringValue
                                    }
                                }
                            } else {
                                record[key] = value.stringValue
                            }
                        }
                        if self.garageIds.contains(Int(record["id"]!)!) == false {
                            self.garage[self.garageIndex] = record
                            self.garageIndex = self.garageIndex + 1
                            self.garageIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.hasMore = true
                    self.activityIndicator.hidden = true
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.hidden = true
                    self.garageCollectionView.hidden = false
                    self.garageCollectionView?.reloadData()
                    self.isLoading = false
                }
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.garage.count > 0 ? self.garage.count : 0
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyGarrageCollectionViewCell
        if self.garage.count > 0 {
            if let record = self.garage[indexPath.row] {
                cell.carName.text = utility.getFormattedStringFromNumber(Double(record["price"]!)!) + " " + utility.__("qar")
                cell.carPrice.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + " " + record["year_"+appDefaultLanguage!]!
                cell.deleteButton.setTitle(utility.__("deleteFromGarageButton"), forState: UIControlState.Normal)
                cell.deleteButton.hidden = false
                cell.deleteActivityIndicator.hidden = true
                if let featuredImage = record["featuredImage"] {
                    let featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    if let imageUrl = NSURL(string: featuredImage) {
                        cell.carImage.hnk_setImageFromURL(imageUrl)
                    }
                }
            }
        }
        return cell
    }
    
    var footerCell: LoadMoreCollectionReusableView!
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "loadMore", forIndexPath: indexPath) as! LoadMoreCollectionReusableView
        self.footerCell = cell
        footerCell.loadMoreActivityIndicator.hidden = false
        footerCell.theEndlabel.text = utility.__("done")
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
                        self.worker.makeUrl("\(self.controller)?act=all&page=\(self.nextCursor)&rowCount=\(self.limit)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let carsList = resultset?.dictionaryValue[self.controller] {
                                for (_, car) in carsList {
                                    var record = [String: String]()
                                    for (key, value) in car {
                                        record[key] = value.stringValue
                                    }
                                    if self.garageIds.contains(Int(record["id"]!)!) == false {
                                        self.garage[self.garageIndex] = record
                                        self.garageIndex = self.garageIndex + 1
                                        self.garageIds.append(Int(record["id"]!)!)
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
                                self.garageCollectionView?.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func deleteFromGarage(sender: AnyObject) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        if isLoading {
            return;
        }
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! MyGarrageCollectionViewCell
        let indexPath = garageCollectionView.indexPathForCell(cell)
        let carId = self.garage[indexPath!.row]!["id"]! as String
        cell.deleteActivityIndicator.hidden = false
        cell.deleteButton.hidden = true
        isLoading = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)/"+carId).request(Worker.Method.DELETE, parameters: [:]) {
                (resultset, pagination, messageError) in
                if let error = messageError {
                    if let statusCode = Int(error["code"]!) {
                        if statusCode == 200 {
                            self.garage[indexPath!.row] = nil
                        } else {
                            self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.getOnlineGarage()
                }
            }
        }
    }
}

