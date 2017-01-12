//
//  UploadedImagesCollectionViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import Haneke

class UploadedImagesCollectionViewController: UICollectionViewController {
    
    var username: UITextField!
    var password: UITextField!
    var firstName: UITextField!
    var lastName: UITextField!
    var phoneNumber: UITextField!

    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var reuseIdentifier = "imageBox"
    var uploadedImages = [Int: [String: String]]()
    var featuredCar: JSON!
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    var imagesIds: [Int] = [Int]()
    var imagesIndex: Int = 0
    var carsId: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "UploadedImagesCollectionViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = utility.__("uploadedImagesTitle")
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        getOnlineUploadedImages()
    }
    
    func getOnlineUploadedImages() {
        self.uploadedImages = [:]
        self.imagesIds = []
        self.imagesIndex = 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("sellcar?steps=6&cars_id=\(newCarAdvertID)").request(Worker.Method.GET) {
                (resultset, pagination, messageError) -> Void in
                if Int(messageError!["code"]!)==401 {
                    self.showSignInAlertAction(nil)
                } else if Int(messageError!["code"]!)==200 {
                    if let carImages = resultset!["sellcar_dt"]![0]["cars_image"].array {
                        for image in carImages {
                            var record = [String: String]()
                            for (key, value) in image {
                                record[key] = value.stringValue
                            }
                            if self.imagesIds.contains(Int(record["id"]!)!) == false {
                                self.uploadedImages[self.imagesIndex] = record
                                self.imagesIndex = self.imagesIndex + 1
                                self.imagesIds.append(Int(record["id"]!)!)
                            }
                        }
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.uploadedImages.count > 0 ? self.uploadedImages.count : 0
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
            columns = 2
        } else {
            columns = 3
        }
        let paddingCount = CGFloat(columns) + 1
        let cellPadding = 10
        let widthWithoutPadding = width - (CGFloat(cellPadding) * paddingCount)
        cellWidth = widthWithoutPadding / CGFloat(columns)
        cellHeight = CGFloat(207)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UploadedImagesCollectionViewCell
        if self.uploadedImages.count > 0 {
            if let record = self.uploadedImages[indexPath.row] {
                if let featuredImage = record["image"] {
                    var featuredImage = featuredImage.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    featuredImage = featuredImage.stringByReplacingOccurrencesOfString("mobile/", withString: "")
                    if let imageUrl = NSURL(string: featuredImage) {
                        cell.carImage.hnk_setImageFromURL(imageUrl)
                    }
                }
                cell.makeDefaultImage.text = utility.__("defaultImage")
                if Int(record["primary_photo"]!) == 1 {
                    cell.makeDefault.hidden = true
                    cell.makeDefaultImage.hidden = false
                } else {
                    cell.makeDefault.hidden = false
                    cell.makeDefaultImage.hidden = true
                    cell.makeDefault.setTitle(utility.__("makeImageDefault"), forState: UIControlState.Normal)
                }
                cell.makeActivityIndicator.hidden = true
                cell.deleteActivityIndicator.hidden = true
                cell.deleteImage.hidden = false
                cell.deleteImage.setTitle(utility.__("deleteImage"), forState: UIControlState.Normal)
            }
        }
        return cell
    }
    
    @IBAction func deleteImage(button: UIButton) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        let view = button.superview!
        let cell = view.superview as! UploadedImagesCollectionViewCell
        let indexPath = self.collectionView!.indexPathForCell(cell)
        let imageId = self.uploadedImages[indexPath!.row]!["id"]! as String
        cell.deleteActivityIndicator.hidden = false
        cell.deleteImage.hidden = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("sellcar/photo/del?cars_id=\(newCarAdvertID)&id=\(imageId)").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) in
                if let error = messageError {
                    if let statusCode = Int(error["code"]!) {
                        if statusCode == 200 {
                            self.uploadedImages[indexPath!.row] = nil
                        } else {
                            self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.getOnlineUploadedImages()
                }
            }
        }
    }

    @IBAction func makeDefault(button: UIButton) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        let view = button.superview!
        let cell = view.superview as! UploadedImagesCollectionViewCell
        let indexPath = self.collectionView!.indexPathForCell(cell)
        let imageId = self.uploadedImages[indexPath!.row]!["id"]! as String
        cell.makeActivityIndicator.hidden = false
        cell.makeDefault.hidden = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("sellcar/photo/primary?cars_id=\(newCarAdvertID)&id=\(imageId)").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if let statusCode = Int(error["code"]!) {
                            if statusCode == 200 {
                                self.uploadedImages[indexPath!.row] = nil
                            } else {
                                self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                            }
                        }
                    }
                    self.getOnlineUploadedImages()
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
        alertController.addAction(UIAlertAction(title: self.utility.__("cancleButton"), style: UIAlertActionStyle.Cancel, handler: goToHomeView))
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
        alertController.addAction(UIAlertAction(title: self.utility.__("cancleButton"), style: UIAlertActionStyle.Cancel, handler: goToHomeView))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func goToHomeView(alert: UIAlertAction) {
        let homeController = self.storyboard!.instantiateViewControllerWithIdentifier("homeView") as! HomeViewController
        self.navigationController?.pushViewController(homeController, animated: true)
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
}
