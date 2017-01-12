//
//  SearchCarViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class SearchCarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var resultsFoundLabel: UILabel!
    @IBOutlet weak var searchResultNumber: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carsTableView: UITableView!
    var username: UITextField!
    var password: UITextField!

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
    var searchPhrase = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SearchCarViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("searchCarTitle")
        resultsFoundLabel.text = utility.__("resultsFoundLabel")
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(SearchCarViewController.getOnlineCars), forControlEvents: UIControlEvents.ValueChanged)
        carsTableView!.addSubview(refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.activityIndicator.hidden = false
        carsTableView.hidden = true
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineCars()
        } else {
            getOfflineCars()
        }
        hasMore = true
    }
    
    func getOnlineCars() {
        self.searchPhrase = ""
        self.nextCursor = 1
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
                self.searchPhrase += "\"user_t|=\":\"" + userType + "\","
            }
            if self.searchPhrase != "" {
                searchPhrase = searchPhrase.substringToIndex(searchPhrase.endIndex.predecessor())
                self.searchPhrase = "&searchPhrase={\(searchPhrase)}"
            }
        }
        let fullUrl = "\(self.controller)?act=\(self.controller)&page=\(self.nextCursor)&rowCount=\(self.limit)\(self.searchPhrase)"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl(fullUrl).requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                let totalCars = pagination?.dictionary!["total"]!.stringValue
                self.searchResultNumber.text = totalCars
                if let carsList = resultset?.dictionaryValue[self.controller] {
                    for (_, car) in carsList {
                        var record = [String: String]()
                        for (key, value) in car {
                            if key == "cars_image" {
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
                    self.nextCursor = 2
                    self.refreshControl.hidden = false
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.hidden = true
                    self.carsTableView.hidden = false
                    self.carsTableView?.reloadData()
                }
            }
        }
    }
    
    func getOfflineCars() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.cars = self.worker.select(Worker.Entities.CARS, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.hidden = true
                self.carsTableView.hidden = false
                self.carsTableView?.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count > 0 ? cars.count : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("carBox", forIndexPath: indexPath) as! BuyCarTableViewCell
        if cell.isEqual(nil) == false {
            if self.cars.count > 0 {
                if let record = self.cars[indexPath.row] {
                    cell.carName.text = record["make_name_"+appDefaultLanguage!]! + " " + record["model_name_"+appDefaultLanguage!]! + " " + record["year_"+appDefaultLanguage!]!
                    cell.carPrice.text = utility.getFormattedStringFromNumber(Double(record["price"]!)!)  + " " + utility.__("qar")
                    cell.carDealer.text = utility.__("dealer") + ": " + record["user_type_"+appDefaultLanguage!]!
                    cell.saveCarActivityIndicator.hidden = true
                    cell.saveAcar.hidden = false
                    cell.savedLabel.hidden = true
                    if Utility.DeviceType.IS_IPAD {
                        cell.backgroundColor = UIColor.clearColor()
                    }
                    if let featuredImage = record["featuredImage"] {
                        let headerImageLink = featuredImage.stringByReplacingOccurrencesOfString("mobile/", withString: "")
                        if let imageUrl = NSURL(string: headerImageLink) {
                            cell.carImage.hnk_setImageFromURL(imageUrl)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if hasMore && isReady {
            if offsetY > contentHeight - scrollView.frame.size.height {
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
                                self.refreshControl.hidden = false
                                self.refreshControl.endRefreshing()
                                self.carsTableView?.reloadData()
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        let newCars = self.worker.select(Worker.Entities.CARS, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")
                        if newCars!.count > 0 {
                            for (id, record) in newCars! {
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
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if let statusCode = Int(error["code"]!) {
                            self.searchCell.saveCarActivityIndicator.hidden = true
                            if statusCode == 200 {
                                self.searchCell.savedLabel.hidden = false
                            } else {
                                if statusCode == 401 {
                                    self.showAlertAction()
                                }
                                self.searchCell.saveAcar.hidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showAlertAction() {
        let alertController = UIAlertController(title: self.utility.__("signinAlertTitle"), message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("username"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            self.username = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("password"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            textField.secureTextEntry = true
            self.password = textField
        }
        alertController.addAction(UIAlertAction(title: self.utility.__("signinButton"), style: UIAlertActionStyle.Default, handler: signin))
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
                            self.showAlertAction()
                        } else {
                            self.saveCar(self.featuredCarId)
                        }
                    }
                }
            } else {
                self.utility.showAlert(self, alertTitle: self.utility.__("warning"), alertMessage: self.utility.__("emptyFields"))
                self.showAlertAction()
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
