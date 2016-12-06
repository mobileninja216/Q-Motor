//
//  ViewCarViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

extension UISegmentedControl {
    func changeUIColors(selectedColor : UIColor) {
        setBackgroundImage(imageWithColor(backgroundColor!), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(imageWithColor(selectedColor), forState: .Selected, barMetrics: .Default)
        setDividerImage(imageWithColor(backgroundColor!), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        setDividerImage(imageWithColor(selectedColor), forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor);
        CGContextFillRect(context!, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

import UIKit
import Social
import GoogleMobileAds

class ViewCarViewController: UIViewController {
    
    @IBOutlet weak var admobViewHeight: NSLayoutConstraint!
    @IBOutlet weak var admobView: GADBannerView!
    
    @IBOutlet weak var dealerHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var featuredAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var featuredActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var savedFeaturedLabel: UILabel!
    @IBOutlet weak var saveFeaturedCarButton: UIButton!
    @IBOutlet weak var dealerPhone: UIButton!
    @IBOutlet weak var dealerName: UILabel!
    @IBOutlet weak var dealerImage: UIImageView!
    @IBOutlet weak var carSellingPointsTableView: UITableView!
    @IBOutlet weak var featuredCarName: UILabel!
    @IBOutlet weak var featuredCarImage: UIImageView!
    @IBOutlet weak var carImagesCollectionView: UICollectionView!
    @IBOutlet weak var carDetailsTableView: UITableView!
    @IBOutlet weak var carDetailsView: UIView!
    @IBOutlet weak var carListView: UIView!
    @IBOutlet weak var carGalleryView: UIView!
    @IBOutlet weak var carContactView: UIView!
    @IBOutlet weak var segmetedControl: UISegmentedControl!
    @IBOutlet weak var featuredView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var carDetails = [Int: [String: String]]()
    let controller = "cars"
    let reuseIdentifier = "carImage"
    var cars = [Int: [String: String]]()
    var carImages = [Int: [String: String]]()
    var carSellingPoints = [Int: [String: String]]()
    var carId: Int = 0
    var carSellingPointIndex: Int = 0
    var carsImagesIds: [Int] = [Int]()
    var carIndex: Int = 0
    var carsSellingPointsIds: [Int] = [Int]()
    var textToShare: String = "Hello"

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "ViewCarViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
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

        self.title = utility.__("viewCarTitle")
        savedFeaturedLabel.text = utility.__("savedLabel")
        
        //To hide Save title of saveFeaturedCarButton
      //  saveFeaturedCarButton.setTitle(utility.__("saveCar"), forState: UIControlState.Normal)
//        saveFeaturedCarButton.imageEdgeInsets = sysDefaultLanguage=="en" ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15) :  UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        if Utility.DeviceType.IS_IPAD {
            featuredAspectRatio.constant = 200
        }
        
        self.segmetedControl.tintColor = UIColor.whiteColor()
        self.segmetedControl.layer.cornerRadius = 0;
        self.segmetedControl.layer.masksToBounds = true;
        self.segmetedControl.layer.borderWidth = 0
        self.segmetedControl.changeUIColors(UIColor.whiteColor())
        var segAttributes: NSDictionary = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.segmetedControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
        segAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.segmetedControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
        
        if self.utility.isConnectedToNetwork() {
            getOnlineCar()
            admobViewHeight.constant = 50
            admobView.adUnitID = "ca-app-pub-6780231693312776/2889514049"
            admobView.rootViewController = self
            admobView.loadRequest(GADRequest())
        } else {
            getOfflineCar()
            admobViewHeight.constant = 0
        }
    }

    @IBAction func changeView(sender: UISegmentedControl) {
        sender.imageForSegmentAtIndex(segmetedControl.selectedSegmentIndex)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        switch segmetedControl.selectedSegmentIndex {
        case 0:
            carDetailsView.hidden = false
            carListView.hidden = true
            carGalleryView.hidden = true
            carContactView.hidden = true
        case 2:
            carListView.hidden = false
            carDetailsView.hidden = true
            carGalleryView.hidden = true
            carContactView.hidden = true
        case 1:
            carGalleryView.hidden = false
            carDetailsView.hidden = true
            carListView.hidden = true
            carContactView.hidden = true
        case 3:
            carContactView.hidden = false
            carDetailsView.hidden = true
            carListView.hidden = true
            carGalleryView.hidden = true
        default:
            break;
        }
    }
    
    func getOfflineCar() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            var record = self.worker.findById(Worker.Entities.CARS, id: self.carId)
            if record?.count==0 {
                record = self.worker.findById(Worker.Entities.CARS_FEATURED, id: self.carId)
            }
            self.carImages = self.worker.select(Worker.Entities.CARS_IMAGES, whereCondition: "cars_id=\(self.carId)", sortBy: "id", isAscending: false, cursor: nil, limit: nil, indexedBy: "index")!
            dispatch_async(dispatch_get_main_queue()) {
                if record?.count>0 {
                    var r = ["key": NSLocalizedString("priceLabel", comment:"Price"), "value": record!["price"]!]
                    self.carDetails[0] = r
                    r = ["key": NSLocalizedString(self.utility.__("year"), comment:self.utility.__("year")), "value": record!["year_"+appDefaultLanguage!]!]
                    self.carDetails[1] = r
                    r = ["key": NSLocalizedString("useDistanceLabel", comment:"Use Distance"), "value": record!["mileage"]!]
                    self.carDetails[2] = r
                    r = ["key": NSLocalizedString("theBackLabel", comment:"The Back"), "value": record!["bodytype_name_"+appDefaultLanguage!]!]
                    self.carDetails[3] = r
                    r = ["key": NSLocalizedString("carTypeLabel", comment:"Car Type"), "value": record!["transmission_name_"+appDefaultLanguage!]!]
                    self.carDetails[4] = r
                    
                    self.dealerName.text = record!["fullname_"+appDefaultLanguage!]!
                    self.dealerPhone.setTitle(record!["phone"]!, forState: UIControlState.Normal)
                    
                    var featuredImage = [String: String]()
                    for (_, carImage) in self.carImages {
                        var image = [String: String]()
                        if Int(carImage["primary_photo"]!) != 1 {
                            image["image"] = carImage["image"]!
                            image["id"] = carImage["id"]!
                            if self.carsImagesIds.contains(Int(carImage["id"]!)!) == false {
                                self.carImages[self.carIndex] = image
                                self.carIndex = self.carIndex + 1
                                self.carsImagesIds.append(Int(carImage["id"]!)!)
                            }
                        } else {
                            featuredImage["image"] = carImage["image"]!
                            featuredImage["id"] = carImage["id"]!
                        }
                    }
                    
                    self.featuredCarName.text = record!["make_name_"+appDefaultLanguage!]! + " " + record!["model_name_"+appDefaultLanguage!]!
                    //+ " " + record!["year_"+appDefaultLanguage!]!
                    if let imageUrl = featuredImage["image"] {
                        let imageUrl = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        if let imageNSUrl = NSURL(string: imageUrl) {
                            self.featuredCarImage.hnk_setImageFromURL(imageNSUrl)
                        }
                    }
                    
                    let carSellingpoint = self.worker.select(Worker.Entities.CARS_SELLINGPOINT, whereCondition: "cars_id=\(self.carId)", sortBy: "id", isAscending: false, cursor: nil, limit: nil, indexedBy: "index")!
                    for (_, carSPoint) in carSellingpoint {
                        var sellingPoint = [String: String]()
                        sellingPoint["sellingpoint_name_"+appDefaultLanguage!] = carSPoint["sellingpoint_name_"+appDefaultLanguage!]
                        if self.carsSellingPointsIds.contains(Int(carSPoint["id"]!)!) == false {
                            self.carSellingPoints[self.carSellingPointIndex] = sellingPoint
                            self.carSellingPointIndex = self.carSellingPointIndex + 1
                            self.carsSellingPointsIds.append(Int(carSPoint["id"]!)!)
                        }
                    }
                }
                self.featuredView.hidden = false
                self.containerView.hidden = false
                self.segmetedControl.hidden = false
                self.activityIndicator.hidden = true
                self.carDetailsTableView.reloadData()
                self.carImagesCollectionView.reloadData()
                self.carSellingPointsTableView.reloadData()
                
            }
        }
    }
    
    @IBAction func callNumber(sender: UIButton) {
        if let phoneNumber = sender.titleLabel?.text {
            let phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
        }
    }
    
    func getOnlineCar() {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        self.activityIndicator.hidden = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("cars/\(self.carId)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                dispatch_async(dispatch_get_main_queue()) {
                    let record = resultset!["cars"][0]
                    var r = ["key": self.utility.__("priceLabel"), "value": self.utility.getFormattedStringFromNumber(record["price"].doubleValue) + " " + self.utility.__("qar")]
                    self.carDetails[0] = r
//                    r = ["key": self.utility.__("colourLabel"), "value": record["color_name_"+appDefaultLanguage!].stringValue]
                    r = ["key": NSLocalizedString(self.utility.__("year"), comment:self.utility.__("year")), "value": record["year_"+appDefaultLanguage!].stringValue]
                    self.carDetails[1] = r
                    r = ["key": self.utility.__("useDistanceLabel"), "value": self.utility.getFormattedStringFromNumber(record["mileage"].doubleValue)]
                    self.carDetails[2] = r
                    r = ["key": self.utility.__("theBackLabel"), "value": record["bodytype_name_"+appDefaultLanguage!].stringValue]
                    self.carDetails[3] = r
                    r = ["key": self.utility.__("carTypeLabel"), "value": record["transmission_name_"+appDefaultLanguage!].stringValue]
                    self.carDetails[4] = r
                    
                    self.dealerName.text = record["user_t"]==2 ? record["fullname_"+appDefaultLanguage!].stringValue.uppercaseString : self.utility.__("individual")
                    if record["user_t"].int==2 {
                        self.dealerHeaderHeight.constant = 80
                        self.dealerImage.hidden = false
                        if let imageUrl = record["header"].string {
                            let imageUrl = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                            if let imageNSUrl = NSURL(string: imageUrl) {
                                self.dealerImage.tag = Int(record["user_id"].intValue)
                                self.dealerImage.hnk_setImageFromURL(imageNSUrl)
                            }
                        }
//                        self.dealerImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: record["header"].stringValue)!)!)
                    } else {
                        self.dealerHeaderHeight.constant = 0
                        self.dealerImage.hidden = true
                    }
                    if let phone = record["phone1"].string {
                        self.dealerPhone.setTitle(phone, forState: UIControlState.Normal)
                    } else if let phone = record["phone2"].string {
                        self.dealerPhone.setTitle(phone, forState: UIControlState.Normal)
                    } else if let phone = record["phone"].string {
                        self.dealerPhone.setTitle(phone, forState: UIControlState.Normal)
                    }
                    self.saveFeaturedCarButton.tag = record["id"].intValue
                    
                    var featuredImage = [String: String]()
                    featuredImage["image"] = record["cars_image"][0]["image"].stringValue
                    featuredImage["id"] = record["cars_image"][0]["id"].stringValue
                    for (_, carImage) in record["cars_image"] {
                        var image = [String: String]()
                        if carImage["primary_photo"].int != 1 {
                            image["image"] = carImage["image"].stringValue
                            image["id"] = carImage["id"].stringValue
                            if self.carsImagesIds.contains(carImage["id"].int!) == false {
                                self.carImages[self.carIndex] = image
                                self.carIndex = self.carIndex + 1
                                self.carsImagesIds.append(carImage["id"].int!)
                            }
                        } else {
                            featuredImage["image"] = carImage["image"].stringValue
                            featuredImage["id"] = carImage["id"].stringValue
                        }
                    }
                    var trimValue: String = ""
                    if let trim = record["trim_name_"+appDefaultLanguage!].string {
                        trimValue = " " + trim
                    }
                    self.featuredCarName.text = record["make_name_"+appDefaultLanguage!].stringValue + " " + record["model_name_"+appDefaultLanguage!].stringValue + " " + trimValue
                        //+ " " + record["year_"+appDefaultLanguage!].stringValue
                    
                    if let imageUrl = featuredImage["image"] {
                        let imageUrl = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        if let imageNSUrl = NSURL(string: imageUrl) {
                            self.featuredCarImage.hnk_setImageFromURL(imageNSUrl)
                        }
                    }
                    
                    for (_ , carSellingPoint) in record["cars_sellingpoint"] {
                        var sellingPoint = [String: String]()
                        sellingPoint["sellingpoint_name_"+appDefaultLanguage!] = carSellingPoint["sellingpoint_name_"+appDefaultLanguage!].stringValue
                        if self.carsSellingPointsIds.contains(carSellingPoint["id"].int!) == false {
                            self.carSellingPoints[self.carSellingPointIndex] = sellingPoint
                            self.carSellingPointIndex = self.carSellingPointIndex + 1
                            self.carsSellingPointsIds.append(carSellingPoint["id"].int!)
                        }
                    }
                    self.featuredView.hidden = false
                    self.containerView.hidden = false
                    self.segmetedControl.hidden = false
                    self.activityIndicator.hidden = true
                    self.carDetailsTableView.reloadData()
                    self.carImagesCollectionView.reloadData()
                    self.carSellingPointsTableView.reloadData()
                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == carDetailsTableView {
            return carDetails.count>0 ? carDetails.count : 0
        } else {
            return carSellingPoints.count / 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == carSellingPointsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("sellingPointBox") as! CarSellingPointTableViewCell
            if Utility.DeviceType.IS_IPAD {
                cell.backgroundColor = UIColor.clearColor()
            }
            if self.carSellingPoints.count > 0 {
                let index = indexPath.row * 2
                if let record = self.carSellingPoints[index] {
                    cell.leftSellingPoint.text = record["sellingpoint_name_"+appDefaultLanguage!]!
                }
                if let record = self.carSellingPoints[index+1] {
                    cell.rightSellingPoint.text = record["sellingpoint_name_"+appDefaultLanguage!]!
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("carDetailsBox") as! ViewCarTableViewCell
            if Utility.DeviceType.IS_IPAD {
                cell.backgroundColor = UIColor.clearColor()
            }
            if self.carDetails.count > 0 {
                if let record = self.carDetails[indexPath.row] {
                    cell.rightText.text = record["key"]!
                    cell.leftText.text = record["value"]!
                }
            }
            return cell
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.carImages.count > 0 ? self.carImages.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    var cellWidth: CGFloat = CGFloat(100)
    var cellHeight: CGFloat = CGFloat(80)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(collectionView.bounds)
        var columns = 2
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            columns = 2
        } else {
            columns = 3
        }
        let paddingCount = CGFloat(columns) + 1
        let cellPadding = 10
        let widthWithoutPadding = width - (CGFloat(cellPadding) * paddingCount)
        cellWidth = widthWithoutPadding / CGFloat(columns)
        cellHeight = CGFloat(150)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CarImagesCollectionViewCell
        if self.carImages.count > 0 {
            if let record = self.carImages[indexPath.row] {
                if let featuredImage = record["image"] {
                    let featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    if let imageUrl = NSURL(string: featuredImage) {
                        cell.carImage.hnk_setImageFromURL(imageUrl)
                    }
                }
            }
        }
        return cell
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first! as UITouch
        if (touch.view == dealerImage) {
            let dealerCarController = self.storyboard!.instantiateViewControllerWithIdentifier("dealerCarController") as! DealerCarsViewController
            dealerCarController.dealerId = (touch.view?.tag)!
            self.navigationController?.pushViewController(dealerCarController, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewGallery" {
            let galleryController = segue.destinationViewController as! GalleryViewController
            galleryController.carId = Int(carId)
        }
    }
    
    var featuredCarId: String = ""
    @IBAction func savefeaturedCar(sender: UIButton) {
        featuredCarId = String(sender.tag)
        saveCar(featuredCarId)
    }
    
    func saveCar(carID: String) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        savedFeaturedLabel.text = utility.__("savedLabel")
        featuredActivityIndicator.hidden = false
        savedFeaturedLabel.hidden = true
        saveFeaturedCarButton.hidden = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("garage").request(Worker.Method.POST, parameters: ["cars_id": carID]) {
                (resultset, pagination, messageError) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if let statusCode = Int(error["code"]!) {
                            self.featuredActivityIndicator.hidden = true
                            if statusCode == 200 {
                                self.savedFeaturedLabel.hidden = false
                            } else {
                                if statusCode == 401 {
                                    self.showSignInAlertAction(nil)
                                }
                                self.saveFeaturedCarButton.hidden = false
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
        //        alertController.addAction(UIAlertAction(title: self.utility.__("signinButton"), style: UIAlertActionStyle.Default, handler: showSignInAlertAction))
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if self.username.text != nil && self.password.text != nil {
                let parameters = ["user_id": self.username.text!, "password": self.password.text!]
                self.worker.makeUrl("login").requestAndSave(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let user = resultset?.dictionaryValue["users"] {
                            for (key, value) in user {
                                profile[key] = value.stringValue
                            }
                        }
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
            } else {
                self.utility.showAlert(self, alertTitle: self.utility.__("warning"), alertMessage: self.utility.__("emptyFields"))
                self.showSignInAlertAction(nil)
            }
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
                        //                self.showSignInAlertAction(nil)
                        self.utility.showAlert(self, alertTitle: self.utility.__("success"), alertMessage: self.utility.__("registrationMessage"))
                    }
                }
            }
        }
    }

    
    @IBAction func showShareOptions(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "", message: utility.__("shareYourNote"), preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let tweetAction = UIAlertAction(title: utility.__("shareOnTwitter"), style: UIAlertActionStyle.Default) { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                if self.textToShare.characters.count <= 140 {
                    twitterComposeVC.setInitialText("\(self.textToShare)")
                } else {
                    let index = self.textToShare.startIndex.advancedBy(140)
                    let subText = self.textToShare.substringToIndex(index)
                    twitterComposeVC.setInitialText("\(subText)")
                }
                self.presentViewController(twitterComposeVC, animated: true, completion: nil)
            } else {
                self.showAlertMessage(self.utility.__("loginToTwitter"))
            }
        }
        
        let facebookPostAction = UIAlertAction(title: self.utility.__("shareOnFacebook"), style: UIAlertActionStyle.Default) { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookComposeVC.setInitialText("\(self.textToShare)")
                self.presentViewController(facebookComposeVC, animated: true, completion: nil)
            } else {
                self.showAlertMessage(self.utility.__("loginToFacebook"))
            }
        }

        let whatsAppAction = UIAlertAction(title: self.utility.__("shareOnWhatsApp"), style: UIAlertActionStyle.Default) { (action) -> Void in
            let msg: NSString = "to the world of none";
            let titlewithoutspace = msg.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
            if let titlewithoutspace = titlewithoutspace {
                let urlWhats = "whatsapp://send?text=\(titlewithoutspace)"
                let whatsappURL = NSURL(string: urlWhats)
                if UIApplication.sharedApplication().canOpenURL(whatsappURL!) {
                    UIApplication.sharedApplication().openURL(whatsappURL!)
                } else {
                    self.showAlertMessage(self.utility.__("installWhatsApp"))
                }
            } else {
                self.showAlertMessage(self.utility.__("notAllowedString"))
            }
        }
        
        let moreAction = UIAlertAction(title: self.utility.__("moreSocial"), style: UIAlertActionStyle.Default) { (action) -> Void in
            let activityViewController = UIActivityViewController(activityItems: [self.textToShare], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityTypeMail]
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        let dismissAction = UIAlertAction(title: self.utility.__("closeSocialList"), style: UIAlertActionStyle.Cancel) { (action) -> Void in}
        
        
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(whatsAppAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showAlertMessage(message: String!) {
        let alertController = UIAlertController(title:  self.utility.__("socialShare"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: self.utility.__("okay"), style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "viewGallery" && utility.isConnectedToNetwork() {
            return true
        }
        return false
    }
    
}
