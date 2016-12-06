//
//  DealerCarsViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class DealerCarsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carDealerImage: UIImageView!
    @IBOutlet weak var carsTableView: UITableView!
    var username: UITextField!
    var password: UITextField!
    var firstName: UITextField!
    var lastName: UITextField!
    var phoneNumber: UITextField!
    var footerView: UIView!

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var controller = "dealers"
    var cars = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 10
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var carsIds: [Int] = [Int]()
    var carIndex: Int = 0
    var dealerId: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "DealerCarsViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = utility.__("dealerCarsTitile")
        
        carsTableView.rowHeight = 140.0
        refreshControl.addTarget(self, action: #selector(DealerCarsViewController.getOnlineCars), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        carsTableView!.addSubview(refreshControl)
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        self.activityIndicator.hidden = false
        self.carsTableView.hidden = true
        if self.utility.isConnectedToNetwork() {
            getOnlineCars()
        } else {
            getOfflineCars()
        }
        hasMore = true
    }
    
    func getOnlineCars() {
        self.nextCursor = 1
        self.worker.makeUrl("\(self.controller)/\(self.dealerId)?act=cars&page=1&rowCount=\(self.limit)").requestAndSave(Worker.Method.GET, parameters: [:]) {
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
                if let featuredImage = self.cars[0]!["header"] {
                    let headerImageLink = featuredImage.stringByReplacingOccurrencesOfString("mobile/", withString: "")
                    let imageUrl = headerImageLink.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    if let imageUrl = NSURL(string: imageUrl) {
                        self.carDealerImage.hnk_setImageFromURL(imageUrl)
                        self.carDealerImage.hidden = false
                    }
                }
                self.nextCursor = 2
                self.refreshControl.hidden = false
                self.refreshControl.endRefreshing()
                self.activityIndicator.hidden = true
                self.carsTableView.hidden = false
                self.carsTableView?.reloadData()
            }
        }
    }
    
    func getOfflineCars() {
        self.cars = self.worker.select(Worker.Entities.CARS, whereCondition: "user_id=\(self.dealerId)", sortBy: "id", cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
        self.nextCursor = self.nextCursor + 1
        self.activityIndicator.hidden = true
        self.carsTableView.hidden = false
        self.carsTableView?.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count > 0 ? cars.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("carBox", forIndexPath: indexPath) as! BuyCarTableViewCell
        if cell.isEqual(nil) == false {
            if self.cars.count > 0 {
                if let record = self.cars[indexPath.row] {
                    print(record)
                    var trimValue: String = ""
                    if let trim = record["trim_name_"+appDefaultLanguage!] {
                        trimValue = " " + trim
                    }
                    cell.carName.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + trimValue
                    cell.carYear.text = self.utility.__("year") + ": " + self.utility.getFormattedStringFromNumber(Double(record["year_"+appDefaultLanguage!]!)!, groupingSize: 4)
                    cell.carMileage.text = self.utility.__("mileage") + ": " + utility.getFormattedStringFromNumber(Double(record["mileage"]!)!) + " " + self.utility.__("km")
                    cell.carPrice.text = self.utility.__("price") + ": " + self.utility.getFormattedStringFromNumber(Double(record["price"]!)!)  + " " + self.utility.__("qar")
                    cell.saveAcar.tag = Int(record["id"]!)!
                    cell.saveCarActivityIndicator.hidden = true
                    cell.saveAcar.hidden = false
                    cell.savedLabel.hidden = true
                    cell.savedLabel.text = utility.__("savedLabel")
                    if Utility.DeviceType.IS_IPAD {
                        cell.backgroundColor = UIColor.clearColor()
                    }
                    if record["sold_status"] == "1" {
                        cell.carSold.hidden = false
                    } else {
                        cell.carSold.hidden = true
                    }
                    if let featuredImage = record["featuredImage"] {
                        var headerImageLink = featuredImage.stringByReplacingOccurrencesOfString("mobile/", withString: "")
                        headerImageLink = headerImageLink.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        if let imageUrl = NSURL(string: headerImageLink) {
                            cell.carImage.hnk_setImageFromURL(imageUrl)
                        }
                    }
                }
            }
        }
        return cell
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if hasMore && isReady {
            if offsetY > contentHeight - scrollView.frame.size.height {
                footerView.hidden = false
                self.isReady = false
                if utility.isConnectedToNetwork() {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        self.worker.makeUrl("\(self.controller)/\(self.dealerId)?act=cars&page=\(self.nextCursor)&rowCount=\(self.limit)").requestAndSave(Worker.Method.GET, parameters: [:]) {
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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newCars = self.worker.select(Worker.Entities.CARS, whereCondition: "user_id=\(self.dealerId)", sortBy: "id", cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newCars!.count > 0 {
                            for (id, record) in newCars! {
                                self.cars[id + self.cars.count] = record
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isReady = true
                            self.nextCursor = self.nextCursor + 1
                            self.refreshControl.hidden = false
                            self.refreshControl.endRefreshing()
                            self.carsTableView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "viewCar" {
            return true
        }
        return false
    }
    
    var featuredCarId: String = ""
    var searchCell:BuyCarTableViewCell!
    @IBAction func saveACar(sender: UIButton) {
        let button = sender
        let view = button.superview!
        searchCell = view.superview as! BuyCarTableViewCell
        let indexPath = carsTableView.indexPathForCell(searchCell)
        featuredCarId = self.cars[indexPath!.row]!["id"]! as String
        saveCar(featuredCarId)
    }
    
    func saveCar(carID: String) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        searchCell.saveCarActivityIndicator.hidden = false
        searchCell.saveAcar.hidden = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("garage").request(Worker.Method.POST, parameters: ["cars_id": self.featuredCarId]) {
                (resultset, pagination, messageError) in
                if let error = messageError {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let statusCode = Int(error["code"]!) {
                            self.searchCell.saveCarActivityIndicator.hidden = true
                            if statusCode == 200 {
                                self.searchCell.savedLabel.hidden = false
                            } else {
                                if statusCode == 401 {
                                    self.showSignInAlertAction(nil)
                                }
                                self.searchCell.saveAcar.hidden = false
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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewCar" {
            let index = self.carsTableView.indexPathForSelectedRow!.row
            if let car = cars[index] {
                if let carID = car["id"] {
                    let viewCarViewController = segue.destinationViewController as! ViewCarViewController
                    viewCarViewController.carId = Int(carID)!
                }
            }
        }
    }

}
