//
//  FilterViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var toalCarAvaliableLabel: UILabel!
    @IBOutlet weak var halfMillionQARLabel: UILabel!
    @IBOutlet weak var zeroQARLabel: UILabel!
    @IBOutlet weak var priceRangeLabel: UILabel!
    @IBOutlet weak var carsInStockLabel: UILabel!
    @IBOutlet weak var searchCarButton: UIButton!
    @IBOutlet weak var selectModelButton: UIButton!
    @IBOutlet weak var selectTrimButton: UIButton!
    @IBOutlet weak var selectMakeButton: UIButton!
    @IBOutlet weak var segmetedControl: UISegmentedControl!
    @IBOutlet weak var selectYearButton: UIButton!
    @IBOutlet weak var selectMileageButton: UIButton!
    @IBOutlet weak var selectBodytypeButton: UIButton!
    @IBOutlet weak var selectTransmissionButton: UIButton!
    @IBOutlet weak var selectColourButton: UIButton!
    @IBOutlet weak var selectSellertypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selctPriceFromSlider: UISlider!
    @IBOutlet weak var selctPriceToSlider: UISlider!
    
    @IBOutlet weak var homeSearchButton: UIButton!
    @IBOutlet weak var searchSearchButton: UIButton!
    @IBOutlet weak var sellCarSearchButton: UIButton!
    @IBOutlet weak var carDealersSearchButton: UIButton!
    @IBOutlet weak var accountSearchButton: UIButton!

    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let limit: Int = 30
    var nextCursor: Int = 1
    var hasMore: Bool = false
    var isReady: Bool = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "FilterViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("filterTtitle")
//        selctPriceFromSlider.se
        carsInStockLabel.text = utility.__("carsInStockLabel")
        priceRangeLabel.text = utility.__("priceRangeLabel")
        zeroQARLabel.text = utility.__("zeroQARLabel")
        halfMillionQARLabel.text = utility.__("halfMillionQARLabel")
        searchCarButton.setAttributedTitle(NSAttributedString(string: utility.__("searchCarButton"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: UIControlState.Normal)
        
        toalCarAvaliableLabel.text = String(totalAvailableCars)
        
        filterArray = [:]
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
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
    
    func setupUI() {
        
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
        
        self.segmetedControl.layer.cornerRadius = 3.0;
        self.segmetedControl.layer.masksToBounds = true;
        self.segmetedControl.layer.borderWidth = 0
        self.segmetedControl.removeBorders()
        var segAttributes: NSDictionary = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.segmetedControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
        segAttributes = [
            NSForegroundColorAttributeName: UIColor.grayColor()
        ]
        self.segmetedControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
        
        if filterArray["make_id"] != nil && Int(filterArray["make_id"]!)! > 0 {
            self.selectMakeButton.setTitle(filterArray["make_name"]!, forState: UIControlState.Normal)
            self.selectModelButton.enabled = true
        } else {
            self.selectMakeButton.setTitle(utility.__("selectMake"), forState: UIControlState.Normal)
        }
        
        if filterArray["model_id"] != nil && Int(filterArray["model_id"]!)! > 0 {
            self.selectModelButton.setTitle(filterArray["model_name"]!, forState: UIControlState.Normal)
            self.selectTrimButton.enabled = true
        } else {
            self.selectModelButton.setTitle(utility.__("selectModel"), forState: UIControlState.Normal)
        }
        
        if filterArray["trim_id"] != nil && Int(filterArray["trim_id"]!)! > 0 {
            self.selectTrimButton.setTitle(filterArray["trim_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectTrimButton.setTitle(utility.__("selectTrim"), forState: UIControlState.Normal)
        }
        
        if filterArray["year_id"] != nil && Int(filterArray["year_id"]!)! > 0 {
            self.selectYearButton.setTitle(filterArray["year_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectYearButton.setTitle(utility.__("selectYear"), forState: UIControlState.Normal)
        }
        
        if filterArray["mileage"] != nil && Int(filterArray["mileage"]!)! > 0 {
            self.selectMileageButton.setTitle(filterArray["mileage_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectMileageButton.setTitle(utility.__("selectMileage"), forState: UIControlState.Normal)
        }
        
        if filterArray["body_id"] != nil && Int(filterArray["body_id"]!)! > 0 {
            self.selectBodytypeButton.setTitle(filterArray["bodytype_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectBodytypeButton.setTitle(utility.__("selectBodyType"), forState: UIControlState.Normal)
        }
        
        if filterArray["trans_id"] != nil && Int(filterArray["trans_id"]!)! > 0 {
            self.selectTransmissionButton.setTitle(filterArray["transmission_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectTransmissionButton.setTitle(utility.__("selectTransmission"), forState: UIControlState.Normal)
        }
        
        if filterArray["colour_id"] != nil && Int(filterArray["colour_id"]!)! > 0 {
            self.selectColourButton.setTitle(filterArray["colour_name"]!, forState: UIControlState.Normal)
        } else {
            self.selectColourButton.setTitle(utility.__("selectColour"), forState: UIControlState.Normal)
        }
                
        segmetedControl.setTitle(utility.__("individual"), forSegmentAtIndex: 0)
        segmetedControl.setTitle(utility.__("companies"), forSegmentAtIndex: 1)

    }

    
    @IBAction func getPriceFrom(sender: AnyObject) {
        filterArray["price_from"] = String(selctPriceFromSlider.value)
        filterArray["price_to"] = filterArray["price_to"] != nil ? filterArray["price_to"] : "500000"
        rangeLabel.text = "[" + String(filterArray["price_from"]!) + " - " + filterArray["price_to"]! + "]"
    }

    @IBAction func getPriceTo(sender: AnyObject) {
        filterArray["price_to"] = String(selctPriceToSlider.value)
        filterArray["price_from"] = filterArray["price_from"] != nil ? filterArray["price_from"] : "0"
        rangeLabel.text = "[" + String(filterArray["price_from"]!) + " - " + filterArray["price_to"]! + "]"
    }
    
    @IBAction func getType(sender: UISegmentedControl) {
        filterArray["user_t"] = String(selectSellertypeSegmentedControl.selectedSegmentIndex == 0 ? 1 : 2)
    }
    
}
