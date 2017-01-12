//
//  HomeViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
import GoogleMobileAds

var profile: [String: String] = [String: String]()
var filterArray: [String: String] = [String: String]()
var totalAvailableCars: Int = 0

class HomeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var admobViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var admobView: GADBannerView!
    @IBOutlet weak var sliderHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberLabel: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sliderShow: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var pageController: UIPageViewController?
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "slider"
    var reuseIdentifier = "numberPlateBox"
    var slides = [Int: [String: String]]()
    var slidesIds: [Int] = [Int]()
    var slideIndex: Int = 0
    var totalPlates: Int = 0
    var sortPrice = "desc"
    var sliderIndex = 0
    
    private var pageViewController: UIPageViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "HomeViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utility.DeviceType.IS_IPAD {
            sliderHeight.constant = 290
        } else if Utility.DeviceType.IS_IPHONE_FIVE || Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
            sliderHeight.constant = 120
        } else if Utility.DeviceType.IS_IPHONE_SIX {
            sliderHeight.constant = 141
        } else if Utility.DeviceType.IS_IPHONE_SIX_PLUS {
            sliderHeight.constant = 155
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(HomeViewController.startSlider(_:)), userInfo: nil, repeats: true)
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
       
        admobViewHeight.constant = 0

        if self.utility.isConnectedToNetwork() {
            getOnlineHome()
//            admobViewHeight.constant = 50
//            admobView.adUnitID = "ca-app-pub-6780231693312776/2889514049"
//            admobView.rootViewController = self
//            admobView.loadRequest(GADRequest())
        } else {
            getOfflineHome()
//            admobViewHeight.constant = 0
        }
        filterArray = [:]
    }
    
    func startSlider(timer:NSTimer) {
        if slides.count > 0 {
            sliderIndex = sliderIndex + 1
            if sliderIndex >= slides.count {
                sliderIndex = 0
            }
            let firstController = getItemController(sliderIndex)!
            let startingViewControllers: NSArray = [firstController]
            pageController!.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getOfflineHome() {
        self.refreshControl.hidden = true
        self.refreshControl.beginRefreshing()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.slides = self.worker.select(Worker.Entities.SLIDER, whereCondition: nil, sortBy: "id", isAscending: false, cursor: 1, limit: 100, indexedBy: "index")!
            dispatch_async(dispatch_get_main_queue()) {
                let appSetting = preference!.dictionaryForKey("app-setting")
                self.phoneNumberLabel.setTitle(appSetting!["site_phone"] as? String, forState: UIControlState.Normal)
                totalAvailableCars = preference!.integerForKey("totalAvailableCars")
                let homeSubview = self.childViewControllers[1] as! HomeSubViewController
                let carsAvailableLabel = self.utility.__("carsAvailableLabel")
                homeSubview.carsAvailableLabel.text = carsAvailableLabel.stringByReplacingOccurrencesOfString(":value", withString: String(totalAvailableCars))
                self.createPageViewController()
//                self.setupPageControl()
            }
        }
    }
    
    func getOnlineHome() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if appSetting != nil {
                self.phoneNumberLabel.setTitle(appSetting!["site_phone"] as? String, forState: UIControlState.Normal)
            }
            self.worker.makeUrl("setting").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    var setting: [String: String] = [:]
                    if let settingList = resultset!["setting"] {
                        for (_, record) in settingList {
                            setting[record["key"].stringValue] = record["value"].stringValue
                        }
                    }
                    self.phoneNumberLabel.setTitle(setting["site_phone"], forState: UIControlState.Normal)
                    preference!.setValue(setting, forKey: "app-setting")
                    preference!.synchronize()
                }
            }
            
            let homeSubview = self.childViewControllers[1] as! HomeSubViewController
            totalAvailableCars = preference!.integerForKey("totalAvailableCars")
            let carsAvailableLabel = self.utility.__("carsAvailableLabel")
            homeSubview.carsAvailableLabel.text = carsAvailableLabel.stringByReplacingOccurrencesOfString(":value", withString: String(totalAvailableCars))
            self.worker.makeUrl("cars?act=cars&page=1&rowCount=1").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    totalAvailableCars = pagination!["total"].intValue
                    preference!.setValue(totalAvailableCars, forKey: "totalAvailableCars")
                    preference!.synchronize()
                    homeSubview.carsAvailableLabel.text = carsAvailableLabel.stringByReplacingOccurrencesOfString(":value", withString: String(totalAvailableCars))
                }
            }

            self.worker.makeUrl("profile").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if Int(error["code"]!) == 200 {
                            if let user = resultset!["profile"]!["user"].dictionary {
                                if user.count > 0 {
                                    for (key, value) in user {
                                        profile[key] = value.stringValue
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=all").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let makesList = resultset?.dictionaryValue[self.controller] {
                    for (_, make) in makesList {
                        var record = [String: String]()
                        for (key, value) in make {
                            record[key] = value.stringValue
                        }
                        if self.slidesIds.contains(Int(record["id"]!)!) == false {
                            self.slides[self.slideIndex] = record
                            self.slideIndex = self.slideIndex + 1
                            self.slidesIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.createPageViewController()
                }
            }
        }
    }
    
    private func createPageViewController() {
        pageController = (self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController)
        pageController!.dataSource = self
        pageController!.delegate = self
        if slides.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController!.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        sliderShow.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        self.pageControl.numberOfPages = self.slides.count
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! PageItemController
        pageControl.currentPage = itemController.itemIndex
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! PageItemController
        self.pageControl.currentPage = itemController.itemIndex
        if itemController.itemIndex+1 < slides.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
        if itemIndex < slides.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageUrl = slides[itemIndex]!["image"]!
            self.pageControl.currentPage = itemIndex
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return slides.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    @IBAction func callUs(sender: UIButton) {
        if let phoneNumber = sender.titleLabel?.text {
            let phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
        }
    }
    
}
