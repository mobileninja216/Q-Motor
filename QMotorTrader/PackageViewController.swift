//
//  PackageViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class PackageViewController: UIViewController {

    @IBOutlet weak var packageCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "packages"
    var reuseIdentifier = "packageBox"
    var packages = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var packageIds: [Int] = [Int]()
    var packageIndex: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "PackageViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(PackageViewController.getOnlinePackages), forControlEvents: UIControlEvents.ValueChanged)
        packageCollectionView!.addSubview(refreshControl)
        self.packageCollectionView.hidden = true
        self.activityIndicator.hidden = false
        self.nextCursor = 1
    }
    
    func getOnlinePackages() {
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        self.packages = [:]
        self.packageIds = []
        self.packageIndex = 0
        self.nextCursor = 1
        self.hasMore = true
        var userType = 1
        if let profileType = profile["user_t"] {
            userType = Int(profileType)!
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("filter?act=\(self.controller)&page=\(self.nextCursor)&rowCount=\(self.limit)&sortId=asc&searchPhrase={\"user_t|=\":\(userType)}").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            record[key] = value.stringValue
                        }
                        if self.packageIds.contains(Int(record["id"]!)!) == false {
                            self.packages[self.packageIndex] = record
                            self.packageIndex = self.packageIndex + 1
                            self.packageIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.hidden = true
                    self.packageCollectionView.hidden = false
                    self.packageCollectionView?.reloadData()
                }
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.packages.count > 0 ? self.packages.count : 6
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
    }
    
    var cellWidth: CGFloat = CGFloat(100)
    var cellHeight: CGFloat = CGFloat(353)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(collectionView.bounds)
        var columns = 1
        var cellPadding = 0
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            columns = 1
            cellPadding = 0
        } else {
            columns = 2
            cellPadding = 20
        }
        let paddingCount = CGFloat(columns) + 1
        let widthWithoutPadding = width - (CGFloat(cellPadding) * paddingCount)
        let cellWidth = widthWithoutPadding / CGFloat(columns)
        let cellHeight = CGFloat(353)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "packageHeader", forIndexPath: indexPath) as! PackageCollectionReusableView
        cell.packageHeaderLabel.text = utility.__("packageHeaderLabel")
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PackageCollectionViewCell
        if self.packages.count > 0 {
            if let record = self.packages[indexPath.row] {
                
                cell.packagePrice.text = Int(record["pkg_price"]!)! != 0 ? record["pkg_price"]! + " " + utility.__("qar") : utility.__("free")
                cell.firstImage.image = UIImage(named: Int(record["advs_duration"]!)>=1 ? "right" : "wrong")
                cell.secondImage.image = UIImage(named: Int(record["soial"]!)==1 ? "right" : "wrong")
                cell.thirdImage.image = UIImage(named: Int(record["featured"]!)==1 ? "right" : "wrong")
                cell.fourthImage.image = UIImage(named: Int(record["offer"]!)==1 ? "right" : "wrong")
                
                cell.monthViews.text = utility.__("monthViews").stringByReplacingOccurrencesOfString(":month", withString: String(Int(record["advs_duration"]!)!/4))
                cell.socialNetwork.text = utility.__("socialNetwork")
                cell.shareTo.text = utility.__("shareTo")
                cell.specialAds.text = utility.__("specialAds")
                cell.tenTimesMore.text = utility.__("tenTimesMore")
                cell.photoService.text = utility.__("photoService")
                cell.photoServiceSubtitle.text = utility.__("photoServiceSubtitle")
                cell.selectPacakge.setTitle(utility.__("selectPacakge"), forState: UIControlState.Normal)
                
                if Int(record["id"]!) != selectedPackageId {
                    cell.packageName.attributedText = NSAttributedString(string:record["package_name_"+appDefaultLanguage!]!, attributes:[NSForegroundColorAttributeName: utility.colorFromRGB(0xee5b3c)])
                    cell.packageHeader.backgroundColor = utility.colorFromRGB(0xf6f6f6)
                    cell.selectPacakge.backgroundColor = utility.colorFromRGB(0x32af26)
                } else {
                    cell.packageName.attributedText = NSAttributedString(string:record["package_name_"+appDefaultLanguage!]!, attributes:[NSForegroundColorAttributeName: utility.colorFromRGB(0xffffff)])
                    cell.packageHeader.backgroundColor = utility.colorFromRGB(0xee5b3c)
                    cell.selectPacakge.backgroundColor = utility.colorFromRGB(0xee5b3c)
                }
            }
        }
        return cell
    }
    
    @IBAction func selectPackage(sender: UIButton) {
        let view = sender.superview!
        let cell = view.superview?.superview as! PackageCollectionViewCell
        let indexPath = packageCollectionView.indexPathForCell(cell)
        selectedPackageId = Int(self.packages[indexPath!.row]!["id"]!)!
        selectedPackageDuration = Int(self.packages[indexPath!.row]!["advs_duration"]!)!
        packageCollectionView.reloadData()
    }
}
