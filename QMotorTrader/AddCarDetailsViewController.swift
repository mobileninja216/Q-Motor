//
//  AddCarDetailsViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class AddCarDetailsViewController: UIViewController, TagListViewDelegate {

    @IBOutlet weak var containerViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var selectColourButton: UIButton!
    @IBOutlet weak var selectTransmissionButton: UIButton!
    @IBOutlet weak var selectBodytypeButton: UIButton!
    @IBOutlet weak var mileageTextField: UITextField!
    @IBOutlet weak var selectYearButton: UIButton!
    @IBOutlet weak var selectTrimButton: UIButton!
    @IBOutlet weak var selectModelButton: UIButton!
    @IBOutlet weak var selectMakeButton: UIButton!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var phone2TextField: UITextField!
    @IBOutlet weak var phone1TextField: UITextField!
    @IBOutlet weak var carPriceTextField: UITextField!
    @IBOutlet weak var vehicleDetailsLabel: UILabel!
    @IBOutlet weak var vehicleSubtitleLabel: UILabel!
    @IBOutlet weak var vehicleDescriptionLabel: UILabel!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var controller = "sellingpoint"
    var rowCount = 100
    var makes = [Int: [String: String]]()
    var makesIds: [Int] = [Int]()
    var makeIndex: Int = 0
    var tagsList: [String] = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "AddCarDetailsViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleDetailsLabel.text = utility.__("vehicleDetailsLabel")
        vehicleSubtitleLabel.text = utility.__("vehicleSubtitleLabel")
        vehicleDescriptionLabel.text = utility.__("vehicleDescriptionLabel")
        
        tagListView.delegate = self
        
        if Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
            containerViewCenterY.constant = 500
        } else if Utility.DeviceType.IS_IPHONE_FIVE {
            containerViewCenterY.constant = 450
        } else if Utility.DeviceType.IS_IPHONE_SIX {
            containerViewCenterY.constant = 350
        } else if Utility.DeviceType.IS_IPHONE_SIX_PLUS {
            containerViewCenterY.constant = 300
        } else if Utility.DeviceType.IS_IPAD {
            containerViewCenterY.constant = 0
        }

        let selectMileagePaddingView = UIView(frame: CGRectMake(0, 0, 45, self.mileageTextField.frame.height))
        mileageTextField.leftView = selectMileagePaddingView
        mileageTextField.leftViewMode = UITextFieldViewMode.Always
        mileageTextField.attributedPlaceholder = NSAttributedString(string: utility.__("selectMileage"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let carPricePaddingView = UIView(frame: CGRectMake(0, 0, 50, self.carPriceTextField.frame.height))
        carPriceTextField.leftView = carPricePaddingView
        carPriceTextField.leftViewMode = UITextFieldViewMode.Always
        
        carPriceTextField.attributedPlaceholder = NSAttributedString(string: utility.__("price"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let phone1PaddingView = UIView(frame: CGRectMake(0, 0, 50, self.phone1TextField.frame.height))
        phone1TextField.leftView = phone1PaddingView
        phone1TextField.leftViewMode = UITextFieldViewMode.Always
        phone1TextField.attributedPlaceholder = NSAttributedString(string: utility.__("phone1"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let phone2PaddingView = UIView(frame: CGRectMake(0, 0, 50, self.phone2TextField.frame.height))
        phone2TextField.leftView = phone2PaddingView
        phone2TextField.leftViewMode = UITextFieldViewMode.Always
        phone2TextField.attributedPlaceholder = NSAttributedString(string: utility.__("phone2"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddCarDetailsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func getSellingPoints(selectedTags: [String] = []) {
        tagsList = [String]()
        self.tagListView.removeAllTags()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        if selectedTags.count > 0 {
            carDetails["sellingPoints"] = selectedTags.joinWithSeparator(",")
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.rowCount)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let makesList = resultset?.dictionaryValue[self.controller] {
                        for (_, record) in makesList {
                            if selectedTags.contains(record["id"].stringValue) {
                                self.tagsList.append(record["id"].stringValue)
                                self.tagListView.addTag(record["sellingpoint_name_"+appDefaultLanguage!].stringValue, id: record["id"].int!).selected = true
                            } else {
                                self.tagListView.addTag(record["sellingpoint_name_"+appDefaultLanguage!].stringValue, id: record["id"].int!)
                            }
                        }
                        carDetails["sellingPoints"] = self.tagsList.joinWithSeparator(",")
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupUI() {
//        if !filterArray.isEmpty {
            if filterArray["make_id"] != nil && Int(filterArray["make_id"]!)! > 0 {
                carDetails["make_id"] = filterArray["make_id"]!
                self.selectMakeButton.setTitle(filterArray["make_name"], forState: UIControlState.Normal)
                self.selectModelButton.enabled = true
            } else {
                self.selectMakeButton.setTitle(utility.__("selectMake"), forState: UIControlState.Normal)
            }
            
            if filterArray["model_id"] != nil && Int(filterArray["model_id"]!)! > 0 {
                carDetails["model_id"] = filterArray["model_id"]!
                self.selectModelButton.setTitle(filterArray["model_name"], forState: UIControlState.Normal)
                self.selectTrimButton.enabled = true
            } else {
                self.selectModelButton.setTitle(utility.__("selectModel"), forState: UIControlState.Normal)
            }
            
            if filterArray["trim_id"] != nil && Int(filterArray["trim_id"]!)! > 0 {
                carDetails["trim_id"] = filterArray["trim_id"]!
                self.selectTrimButton.setTitle(filterArray["trim_name"], forState: UIControlState.Normal)
            } else {
                self.selectTrimButton.setTitle(utility.__("selectTrim"), forState: UIControlState.Normal)
            }
            
            if filterArray["year_id"] != nil && Int(filterArray["year_id"]!)! > 0 {
                carDetails["year_id"] = filterArray["year_id"]!
                self.selectYearButton.setTitle(filterArray["year_name"], forState: UIControlState.Normal)
            } else {
                self.selectYearButton.setTitle(utility.__("selectYear"), forState: UIControlState.Normal)
            }
            
            if filterArray["body_id"] != nil && Int(filterArray["body_id"]!)! > 0 {
                carDetails["body_id"] = filterArray["body_id"]!
                self.selectBodytypeButton.setTitle(filterArray["bodytype_name"], forState: UIControlState.Normal)
            } else {
                self.selectBodytypeButton.setTitle(utility.__("selectBodyType"), forState: UIControlState.Normal)
            }
            
            if filterArray["trans_id"] != nil && Int(filterArray["trans_id"]!)! > 0 {
                carDetails["trans_id"] = filterArray["trans_id"]!
                self.selectTransmissionButton.setTitle(filterArray["transmission_name"], forState: UIControlState.Normal)
            } else {
                self.selectTransmissionButton.setTitle(utility.__("selectTransmission"), forState: UIControlState.Normal)
            }
            
            if filterArray["colour_id"] != nil && Int(filterArray["colour_id"]!)! > 0 {
                carDetails["colour_id"] = filterArray["colour_id"]!
                self.selectColourButton.setTitle(filterArray["colour_name"], forState: UIControlState.Normal)
            } else {
                self.selectColourButton.setTitle(utility.__("selectColour"), forState: UIControlState.Normal)
            }
//        }

    }

    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        if !tagView.selected {
            tagsList.append(String(tagView.tag))
        } else {
            tagsList = tagsList.filter() {$0 != String(tagView.tag)}
        }
        carDetails["sellingPoints"] = tagsList.joinWithSeparator(",")
        tagView.selected = !tagView.selected
    }
    
}
