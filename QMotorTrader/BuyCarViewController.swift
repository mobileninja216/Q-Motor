//
//  BuyCarViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/5/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BuyCarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    @IBOutlet weak var admobViewHeight: NSLayoutConstraint!
    @IBOutlet weak var admobView: GADBannerView!

    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var sliderShowHeight: NSLayoutConstraint!
    @IBOutlet weak var sliderShow: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var carsTableView: UITableView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var pageViewController: UIPageViewController?
    
    @IBOutlet weak var homeSearchButton: UIButton!
    @IBOutlet weak var searchSearchButton: UIButton!
    @IBOutlet weak var sellCarSearchButton: UIButton!
    @IBOutlet weak var carDealersSearchButton: UIButton!
    @IBOutlet weak var accountSearchButton: UIButton!
    

    
    var username: UITextField!
    var password: UITextField!
    var firstName: UITextField!
    var lastName: UITextField!
    var phoneNumber: UITextField!
    
    var footerView: UIView!
    var pageController: UIPageViewController?
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "cars"
    var cars = [Int: [String: String]]()
    var carsFeatured = [Int: [String: String]]()
    var banners = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 10
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var carsIds: [Int] = [Int]()
    var carIndex: Int = 0
    var carsFeaturedIds: [Int] = [Int]()
    var carsFeaturedIndex: Int = 0
    var bannersIds: [Int] = [Int]()
    var bannerIndex: Int = 0
    var sliderIndex = 0
    var searchPhrase = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "BuyCarViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
//        super.viewWillAppear(animated)
        
        self.homeSearchButton.setTitle(utility.__("homeButton"), forState: UIControlState.Normal)
        self.searchSearchButton.setTitle(utility.__("searchCarButton"), forState: UIControlState.Normal)
        self.sellCarSearchButton.setTitle(utility.__("sellMyCarButton"), forState: UIControlState.Normal)
        self.carDealersSearchButton.setTitle(utility.__("carDealers"), forState: UIControlState.Normal)
        self.accountSearchButton.setTitle(utility.__("myAccountButton"), forState: UIControlState.Normal)
        
        self.homeSearchButton.setImage(UIImage(named: "searchHome"), forState: UIControlState.Normal)
        self.searchSearchButton.setImage(UIImage(named: "searchSearch"), forState: UIControlState.Normal)
        self.sellCarSearchButton.setImage(UIImage(named: "searchSellCar"), forState: UIControlState.Normal)
        self.carDealersSearchButton.setImage(UIImage(named: "searchCarDealers"), forState: UIControlState.Normal)
        self.accountSearchButton.setImage(UIImage(named: "searchAccount"), forState: UIControlState.Normal)
        
        self.updateTextImageButton(homeSearchButton)
        self.updateTextImageButton(searchSearchButton)
        self.updateTextImageButton(sellCarSearchButton)
        self.updateTextImageButton(carDealersSearchButton)
        self.updateTextImageButton(accountSearchButton)

    }
    
    func updateTextImageButton(button : UIButton) {
        // the space between the image and text
        let spacing : CGFloat = 3.0
        
        // lower the text and push it left so it appears centered
        //  below the image
        let imageSize : CGSize = button.imageView!.image!.size
        button.titleEdgeInsets = UIEdgeInsetsMake(
            0.0, -imageSize.width, -(imageSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        let titleSize : CGSize = (button.titleLabel?.text!.sizeWithAttributes([NSFontAttributeName:(button.titleLabel?.font)!]))!
        button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width)
        
        // increase the content height to avoid clipping
        let edgeOffset : CGFloat = fabs(titleSize.height - imageSize.height) / 2.0
        button.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("buyCarTitile")
        searchButton.title = utility.__("searchCarButton")
        
        if Utility.DeviceType.IS_IPAD {
            sliderShowHeight.constant = 290
        } else if Utility.DeviceType.IS_IPHONE_FIVE || Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
            sliderShowHeight.constant = 180
        } else if Utility.DeviceType.IS_IPHONE_SIX {
            sliderShowHeight.constant = 230
        } else if Utility.DeviceType.IS_IPHONE_SIX_PLUS {
            sliderShowHeight.constant = 260
        }
        
        
        
        carsTableView.rowHeight = 140.0
        refreshControl.addTarget(self, action: #selector(BuyCarViewController.getOnlineCars), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        carsTableView!.addSubview(refreshControl)
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        
        carsTableView.delegate = self
        carsTableView?.dataSource = self
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.activityIndicator.hidden = false
        carsTableView.hidden = true
        sliderShow.hidden = true
        self.nextCursor = 1
        
        if self.utility.isConnectedToNetwork() {
            getOnlineCars()
            admobViewHeight.constant = 50
            admobView.adUnitID = "ca-app-pub-6780231693312776/2889514049"
            admobView.rootViewController = self
            admobView.loadRequest(GADRequest())
        } else {
            getOfflineCars()
            admobViewHeight.constant = 0
        }
        
        noResultLabel.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        noResultLabel.hidden = true
    }
    
    func startSlider(timer:NSTimer) {
        if carsFeatured.count > 0 {
            sliderIndex = sliderIndex + 1
            if sliderIndex >= carsFeatured.count {
                sliderIndex = 0
            }
            let firstController = getItemController(sliderIndex)!
            let startingViewControllers: NSArray = [firstController]
            pageController!.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
    }
    
    @IBAction func viewCar(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("viewCar", sender: sender)
    }
    
    func getOnlineCars() {
//        noResultLabel.hidden = true
        self.searchPhrase = ""
        if filterArray.count > 0 {
            if let makeId = filterArray["make_id"] {
                self.searchPhrase += "\"make_id|=\":\"" + makeId + "\","
            }
            if let modelId = filterArray["model_id"] {
                self.searchPhrase += "\"model_id|=\":\"" + modelId + "\","
            }
            if let trimId = filterArray["trim_id"] {
                self.searchPhrase += "\"trim_id|=\":\"" + trimId + "\","
            }
            if let yearId = filterArray["year_id"] {
                self.searchPhrase += "\"year_id|=\":\"" + yearId + "\","
            }
            if let mileageId = filterArray["mileage"] {
                self.searchPhrase += "\"mileage|=\":\"" + mileageId + "\","
            }
            if let bodyId = filterArray["body_id"] {
                self.searchPhrase += "\"body_id|=\":\"" + bodyId + "\","
            }
            if let transId = filterArray["trans_id"] {
                self.searchPhrase += "\"trans_id|=\":\"" + transId + "\","
            }
            if let colourId = filterArray["colour_id"] {
                self.searchPhrase += "\"colour_id|=\":\"" + colourId + "\","
            }
            if let userType = filterArray["user_t"] {
                print(filterArray["user_t"])
                self.searchPhrase += "\"user_t|=\":\"" + userType + "\","
            }
            if let priceFrom = filterArray["price_from"] {
                self.searchPhrase += "\"price|>=\":\(priceFrom),"
            }
            if let priceTo = filterArray["price_to"] {
                self.searchPhrase += "\"price|<=\":\(priceTo)"
            }
            
            if self.searchPhrase != "" {
                searchPhrase = searchPhrase.substringToIndex(searchPhrase.endIndex.predecessor())
                self.searchPhrase = "&searchPhrase={\(searchPhrase)}"
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("\(self.controller)?act=carsFeatured&page=1&rowCount=10\(self.searchPhrase)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let carsList = resultset?.dictionaryValue["cars_featured"] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            if key == "cars_image" {
                                record["featuredImage"] = value[0]["image"].stringValue
                                for (_, carImage) in value {
                                    if carImage["primary_photo"].int == 1 {
                                        record["featuredImage"] = carImage["image"].stringValue
                                        break
                                    }
                                }
                            } else {
                                record[key] = value.stringValue
                            }
                        }
                        if self.carsFeaturedIds.contains(Int(record["id"]!)!) == false {
                            self.carsFeatured[self.carsFeaturedIndex] = record
                            self.carsFeaturedIndex = self.carsFeaturedIndex + 1
                            self.carsFeaturedIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if self.carsFeatured.count > 0 {
                        self.sliderShow.hidden = true
                        self.createPageViewController()
                        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(BuyCarViewController.startSlider(_:)), userInfo: nil, repeats: true)
                    } else {
                        self.sliderShowHeight.constant = 0
                        self.sliderShow.hidden = true
                        if self.cars.count <= 0 && self.carsFeatured.count <= 0 {
                            self.noResultLabel.hidden = true
                            self.activityIndicator.hidden = true
                        }
                    }
                }
            }
            self.worker.makeUrl("\(self.controller)?act=\(self.controller)&page=1&rowCount=\(self.limit)\(self.searchPhrase)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            if key == "cars_image" {
                                record["featuredImage"] = value[0].stringValue
                                for (_, carImage) in value {
                                    if carImage["primary_photo"].int == 1 {
                                        record["featuredImage"] = carImage["image"].stringValue
                                    }
                                }
                            } else {
                                record[key] = value.stringValue
                            }
                        }
                        if self.carsIds.contains(Int(record["id"]!)!) == false {
                            self.cars[self.carIndex] = record
                            self.carIndex = self.carIndex + 1
                            self.carsIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                self.worker.makeUrl("slider?act=all").requestAndSave(Worker.Method.GET) {
                    (resultset, pagination) in
                    if let makesList = resultset?.dictionaryValue["slider"] {
                        for (_, make) in makesList {
                            var record = [String: String]()
                            for (key, value) in make {
                                record[key] = value.stringValue
                            }
                            if self.bannersIds.contains(Int(record["id"]!)!) == false {
                                self.banners[self.bannerIndex] = record
                                self.bannerIndex = self.bannerIndex + 1
                                self.bannersIds.append(Int(record["id"]!)!)
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.hidden = true
                    self.carsTableView.hidden = false
                    self.carsTableView?.reloadData()
                    
                    if self.cars.count <= 0 && self.carsFeatured.count <= 0 {
                        self.noResultLabel.hidden = false
                        self.activityIndicator.hidden = true
                        self.carsTableView.hidden = true
                        self.sliderShow.hidden = true
                    } else {
                        self.noResultLabel.hidden = true
                    }
                }
            }
        }
    }
    
    func getOfflineCars() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.cars = self.worker.select(Worker.Entities.CARS, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            self.carsFeatured = self.worker.select(Worker.Entities.CARS_FEATURED, whereCondition: nil, sortBy: "id", isAscending: false, cursor: nil, limit: 10, indexedBy: "index")!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.carsTableView!.hidden = false
                self.activityIndicator.hidden = true
                self.sliderShow.hidden = true
                self.createPageViewController()
                self.carsTableView.hidden = false
                self.carsTableView?.reloadData()
            }
        }
    }
    
    private func createPageViewController() {
        pageController = (self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController)
        pageController!.dataSource = self
        pageController!.delegate = self
        if carsFeatured.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController!.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        sliderShow.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        //        self.pageControl.numberOfPages = self.cars.count
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! FeaturedCarViewController
        //        pageControl.currentPage = itemController.itemIndex
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! FeaturedCarViewController
        //        self.pageControl.currentPage = itemController.itemIndex
        if itemController.itemIndex+1 < carsFeatured.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> FeaturedCarViewController? {
        if itemIndex < carsFeatured.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("FeaturedCarItemController") as! FeaturedCarViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.record = carsFeatured[itemIndex]!
            //            self.pageControl.currentPage = itemIndex
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return carsFeatured.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count > 0 ? cars.count : 6
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.startAnimating()
        footerView.hidden = true
        let activityIndicatorHeight: CGFloat = CGFloat(24)
        let activityIndicatorWidth: CGFloat = CGFloat(24)
        let footerViewWidth: CGFloat = CGFloat(tableView.frame.size.width)
        activityIndicator.frame = CGRectMake(((footerViewWidth/2.0) - (activityIndicatorWidth/2.0)), (activityIndicatorHeight/2.0), activityIndicatorWidth, activityIndicatorHeight)
        footerView.addSubview(activityIndicator)
        return footerView
    }
    
    var index: Int = 0
    var factor: Int = 8
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let bannerBoxCell = tableView.dequeueReusableCellWithIdentifier("bannerBox") as! BannerTableViewCell
        let carBoxCell = tableView.dequeueReusableCellWithIdentifier("carBox") as! BuyCarTableViewCell
        if (indexPath.row % 8 == 0 && indexPath.row != 0 && index < self.banners.count) ||  indexPath.row == 0/*&& index > -1*/ {
            if let record = self.banners[index] {
                bannerBoxCell.tag = index
                index = index + 1
                if let featuredImage = record["image"] {
                    let featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    if let imageUrl = NSURL(string: featuredImage) {
                        bannerBoxCell.carImage.hnk_setImageFromURL(imageUrl)
                    }
                }
            }
            if Utility.DeviceType.IS_IPAD {
                bannerBoxCell.backgroundColor = UIColor.clearColor()
            }
            return bannerBoxCell
        } else {
            if self.cars.count > 0 {
                if index >= self.banners.count  {
                    index = 0
                }
                let thatIndex = indexPath.row >= 8 ? indexPath.row - (indexPath.row/8) : indexPath.row
                if let record = self.cars[thatIndex] {
                    carBoxCell.tag = -1
                    var trimValue: String = ""
                    if let trim = record["trim_name_"+appDefaultLanguage!] {
                        trimValue = " " + trim
                    }
                    carBoxCell.carName.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + trimValue
                    carBoxCell.carYear.text = self.utility.__("year") + ": " + self.utility.getFormattedStringFromNumber(Double(record["year_"+appDefaultLanguage!]!)!, groupingSize: 4)
                    carBoxCell.carMileage.text = self.utility.__("mileage") + ": " + utility.getFormattedStringFromNumber(Double(record["mileage"]!)!) + " " + self.utility.__("km")
                    carBoxCell.carPrice.text = self.utility.__("price") + ": " + self.utility.getFormattedStringFromNumber(Double(record["price"]!)!)  + " " + self.utility.__("qar")
                    carBoxCell.savedLabel.hidden = true
                    carBoxCell.savedLabel.text = utility.__("savedLabel")
                    carBoxCell.saveCarActivityIndicator.hidden = true
                    carBoxCell.saveAcar.hidden = false
                    if Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS || Utility.DeviceType.IS_IPHONE_FIVE {
                        carBoxCell.saveAcar.hidden = true
                    }
                    if Utility.DeviceType.IS_IPAD {
                        carBoxCell.backgroundColor = UIColor.clearColor()
                    }
                    if record["sold_status"] == "1" {
                        carBoxCell.carSold.hidden = false
                    } else {
                        carBoxCell.carSold.hidden = true
                    }
                    if let featuredImage = record["featuredImage"] {
                        let featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        if let imageUrl = NSURL(string: featuredImage) {
                            carBoxCell.carImage.hnk_setImageFromURL(imageUrl)
                        }
                    } else {
                        var carImages = self.worker.select(Worker.Entities.CARS_IMAGES, whereCondition: "cars_id=\(Int(record["id"]!)!)", sortBy: "id", isAscending: false, cursor: nil, limit: 1, indexedBy: "index")!
                        if carImages.count > 0 {
                            if let featuredImage = carImages[0]!["image"] {
                                let featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                                if let imageUrl = NSURL(string: featuredImage) {
                                    carBoxCell.carImage.hnk_setImageFromURL(imageUrl)
                                }
                            }
                        }
                    }
                }
            }
            return carBoxCell
        }
    }
    
    var selectedBanner = [String: String]()
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        print(cell!.tag)
        if cell!.tag != -1 {
            if indexPath.row / 8 <= self.banners.count && indexPath.row % 8 == 0 {
                selectedBanner = banners[cell!.tag]!
                performSegueWithIdentifier("viewBanner", sender: nil)
            }
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "viewBanner" {
            return false
        }
        return true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if  isReady {
            if offsetY > contentHeight - scrollView.frame.size.height {
                footerView.hidden = false
                self.isReady = false
                if utility.isConnectedToNetwork() {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        self.worker.makeUrl("\(self.controller)?act=\(self.controller)&page=\(self.nextCursor)&rowCount=\(self.limit)\(self.searchPhrase)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                            (resultset, pagination) in
                            if let carsList = resultset?.dictionaryValue[self.controller] {
                                for (_, car) in carsList {
                                    var record = [String: String]()
                                    for (key, value) in car {
                                        if key == "cars_image" {
                                            record["featuredImage"] = value[0]["image"].stringValue
                                            for (_, carImage) in value {
                                                if carImage["primary_photo"].int == 1 {
                                                    record["featuredImage"] = carImage["image"].stringValue
                                                    break
                                                }
                                            }
                                        } else {
                                            record[key] = value.stringValue
                                        }
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
                } else {
                    let newCars = self.worker.select(Worker.Entities.CARS, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
                    self.nextCursor = self.nextCursor + 1
                    if newCars.count > 0 {
                        for (id, record) in newCars {
                            self.cars[id + self.cars.count] = record
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isReady = true
                        self.nextCursor += 1
                        self.refreshControl.hidden = false
                        self.refreshControl.endRefreshing()
                        self.carsTableView?.reloadData()
                    }
                }
            }
        }
    }
    
    var featuredCarId: String = ""
    var cell: BuyCarTableViewCell?
    @IBAction func saveACar(sender: UIButton) {
        let button = sender
        let view = button.superview!
        cell = view.superview as? BuyCarTableViewCell
        let indexPath = carsTableView.indexPathForCell(cell!)
        featuredCarId = self.cars[indexPath!.row]!["id"]! as String
        saveCar(featuredCarId)
    }
    
    func saveCar(carId: String) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        cell!.saveCarActivityIndicator.hidden = false
        cell!.saveAcar.hidden = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("garage").request(Worker.Method.POST, parameters: ["cars_id": carId]) {
                (resultset, pagination, messageError) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if let statusCode = Int(error["code"]!) {
                            self.cell!.saveCarActivityIndicator.hidden = true
                            if statusCode == 200 {
                                self.cell!.savedLabel.hidden = false
                            } else {
                                if statusCode == 401 {
                                    self.showSignInAlertAction(nil)
                                }
                                self.cell!.saveAcar.hidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showSignUpAlertAction(alert: UIAlertAction!) {
        let alertController = UIAlertController(title: self.utility.__("signupAlertTitle"), message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("firstName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.firstName = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("lastName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.lastName = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("phoneNumber"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.phoneNumber = textField
        }
        alertController.addAction(UIAlertAction(title: self.utility.__("signupButton"), style: UIAlertActionStyle.Default, handler: signup))
        alertController.addAction(UIAlertAction(title: self.utility.__("cancleButton"), style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showSignInAlertAction(alert: UIAlertAction!) {
        let alertController = UIAlertController(title: self.utility.__("signinAlertTitle"), message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("username"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.username = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("password"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            textField.secureTextEntry = true
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.password = textField
        }
        alertController.addAction(UIAlertAction(title: self.utility.__("signinButton"), style: UIAlertActionStyle.Default, handler: signin))
        alertController.addAction(UIAlertAction(title: self.utility.__("signupButton"), style: UIAlertActionStyle.Default, handler: showSignUpAlertAction))
        alertController.addAction(UIAlertAction(title: self.utility.__("cancleButton"), style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func signin(alert: UIAlertAction!) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        if username.text != nil && password.text != nil {
            let parameters = ["user_id": username.text!, "password": password.text!]
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("login").requestAndSave(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination) -> Void in
                    if let user = resultset?.dictionaryValue["users"] {
                        for (key, value) in user {
                            profile[key] = value.stringValue
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        if resultset?.count <= 0 {
                            self.showSignInAlertAction(nil)
                        } else {
                            if let accessToken = resultset!["accessToken"].string {
                                preference!.setValue(accessToken, forKey: "accessToken")
                                preference!.synchronize()
                            }
                            self.saveCar(self.featuredCarId)
                        }
                    }
                }
            }
        } else {
            self.utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("emptyFields"))
            self.showSignInAlertAction(nil)
        }
    }
    
    func signup(alert: UIAlertAction!) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        let parameters = ["first_name": firstName.text!, "last_name": lastName.text!, "phone": phoneNumber.text!]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("register").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                        self.showSignUpAlertAction(nil)
                    } else {
                        self.utility.showAlert(self, alertTitle: self.utility.__("success"), alertMessage: self.utility.__("registrationMessage"))
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewBanner" {
            let navigation = segue.destinationViewController as! UINavigationController
            let webview = navigation.viewControllers.first as! WebViewController
            webview.pageName = selectedBanner["title_"+appDefaultLanguage!]!
            webview.pageUrl = selectedBanner["url"]!
        }
        if segue.identifier == "viewCar" {
            let index = self.carsTableView.indexPathForSelectedRow!.row
            let thatIndex = index >= 8 ? index - (index/8) : index
            if let car = cars[thatIndex] {
                if let carID = car["id"] {
                    let viewCarViewController = segue.destinationViewController as! ViewCarViewController
                    viewCarViewController.carId = Int(carID)!
                }
            }
        }
    }
    
}
