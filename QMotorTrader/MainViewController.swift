//
//  MainViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var homeArButton: UIButton!
    @IBOutlet weak var homeEnButton: UIButton!
    @IBOutlet weak var sellMyCarArButton: UIButton!
    @IBOutlet weak var sellMyCarEnButton: UIButton!
    @IBOutlet weak var butyAcarArButton: UIButton!
    @IBOutlet weak var butyAcarEnButton: UIButton!
    @IBOutlet weak var carRentalArButton: UIButton!
    @IBOutlet weak var carRentalEnButton: UIButton!
    @IBOutlet weak var myAccountArButton: UIButton!
    @IBOutlet weak var myAccountEnButton: UIButton!
    @IBOutlet weak var carDealersArButton: UIButton!
    @IBOutlet weak var carDealersEnButton: UIButton!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var loaderView: UIView!
    
    @IBOutlet weak var imgVWBanner: UIImageView!

    
    var utility: Utility = Utility.sharedInstance
    var worker: Worker = Worker.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MainViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
        
        requstNewBanner()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let preference = NSUserDefaults.standardUserDefaults()
        let accessToken = preference.stringForKey("accessToken")
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        if accessToken != nil {
            let parameters = ["accessToken": accessToken!]
            if utility.isConnectedToNetwork() {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    self.worker.makeUrl("login").requestAndSave(Worker.Method.POST, parameters: parameters) {
                        (resultset, pagination) -> Void in
                        if let user = resultset?.dictionaryValue["users"] {
                            for (key, value) in user {
                                profile[key] = value.stringValue
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            if resultset?.count > 0 {
                                if let accessToken = resultset!["accessToken"].string {
                                    NSUserDefaults.standardUserDefaults().setValue(accessToken, forKey: "accessToken")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                }
                            }
                            self.loaderView.hidden = true
                            self.mainContainer.hidden = false
                        }
                    }
                }
            } else {
                self.loaderView.hidden = true
                self.mainContainer.hidden = false
            }
        } else {
            self.loaderView.hidden = true
            self.mainContainer.hidden = false
        }
        
        homeArButton.layer.borderColor = UIColor.whiteColor().CGColor
        homeArButton.layer.borderWidth = 2
        homeArButton.titleLabel?.textAlignment = .Right
        
        homeEnButton.layer.borderColor = UIColor.whiteColor().CGColor
        homeEnButton.layer.borderWidth = 2
        
        sellMyCarArButton.layer.borderColor = UIColor.whiteColor().CGColor
        sellMyCarArButton.layer.borderWidth = 2
//        sellMyCarArButton.titleLabel?.textAlignment = NSTextAlignment.Right
//        sellMyCarArButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right


        
        sellMyCarEnButton.layer.borderColor = UIColor.whiteColor().CGColor
        sellMyCarEnButton.layer.borderWidth = 2
        
        butyAcarArButton.layer.borderColor = UIColor.whiteColor().CGColor
        butyAcarArButton.layer.borderWidth = 2
        
        butyAcarEnButton.layer.borderColor = UIColor.whiteColor().CGColor
        butyAcarEnButton.layer.borderWidth = 2
//        butyAcarEnButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left

        
        carDealersArButton.layer.borderColor = UIColor.whiteColor().CGColor
        carDealersArButton.layer.borderWidth = 2
        
        carDealersEnButton.layer.borderColor = UIColor.whiteColor().CGColor
        carDealersEnButton.layer.borderWidth = 2
        
        myAccountArButton.layer.borderColor = UIColor.whiteColor().CGColor
        myAccountArButton.layer.borderWidth = 2
        
        myAccountEnButton.layer.borderColor = UIColor.whiteColor().CGColor
        myAccountEnButton.layer.borderWidth = 2
        
//        carRentalArButton.layer.borderColor = UIColor.whiteColor().CGColor
//        carRentalArButton.layer.borderWidth = 2
        
//        carRentalEnButton.layer.borderColor = UIColor.whiteColor().CGColor
//        carRentalEnButton.layer.borderWidth = 2
    }
    
    func requstNewBanner () {
        //Aims
    let request = NSMutableURLRequest(URL: NSURL(string: "http://api.qmotor.com/v1/bannersmobile?act=main&page=1&rowCount=1&sortId=desc")!)
    request.HTTPMethod = "GET"
//    let postString = "id=13&name=Jack"
//    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
        guard error == nil && data != nil else {                                                          // check for fundamental networking error
            print("error=\(error)")
            return
        }
        
        if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
        }
        
        let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
        let result = self.convertStringToDictionary(responseString!)
        let dict = result!["bannersmobile"]![0] as AnyObject //as Dictionary
        let url_image_ar = dict["url_image_ar"]
        let url_image_en = dict["url_image_en"] as! String
        
//        let imageUrl = NSURL(string: url_image_en) {
//            imgVWBanner.carImage.hnk_setImageFromURL(imageUrl)
        if let url = NSURL(string: url_image_en) {
            
            self.imgVWBanner.hnk_setImageFromURL(url)

     }

//            imgVWBanner.downloadedFrom(link:url_image_en)

        print("responseString = \(url_image_ar)  ......... \(url_image_en)")
    }
    task.resume()
   
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
    do {
    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
    return json
    } catch {
    print("Something went wrong")
    }
    }
    return nil
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="viewsInEnglish" || segue.identifier=="viewsInArabic" {
            appDefaultLanguage = segue.identifier=="viewsInEnglish" ? "en" : "ar"
        } else if segue.identifier=="carRentalEn" || segue.identifier=="carRentalAr" {
            appDefaultLanguage = segue.identifier=="carRentalEn" ? "en" : "ar"
        }
        let path = NSBundle.mainBundle().pathForResource(appDefaultLanguage=="en" ? "en" : "ar-QA", ofType: "lproj")
        bundle = NSBundle(path: path!)
        if segue.identifier=="carRentalEn" || segue.identifier=="carRentalAr" || segue.identifier == "carRental" {
            let navigation = segue.destinationViewController as! UINavigationController
            let webview = navigation.viewControllers.first as! WebViewController
            webview.pageName = "Car rental"
            webview.pageUrl = "http://qmotor.com/rent-car-qatar/" + appDefaultLanguage!
        }
    }

}
