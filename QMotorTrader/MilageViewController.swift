//
//  MileageViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 9/10/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MileageViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mileagePickerView: UIPickerView!
    
    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var mileages = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var controller = "mileage"
    var hasMore: Bool = false
    var isReady: Bool = true
    var mileagesIds: [Int] = [Int]()
    var mileageIndex: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MileageViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.navigationItem.title = utility.__("mileageTitle")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineMileages()
        } else {
            getOfflineMileages()
        }
        hasMore = true
    }
    
    func getOfflineMileages() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.mileages = self.worker.select(Worker.Entities.YEAR, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.mileagePickerView.reloadAllComponents()
            }
        }
    }
    
    func getOnlineMileages() {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        self.nextCursor = 1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortName_\(appDefaultLanguage!)=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.mileages[0] = ["id": "0", "name_en": "", "name_ar": ""]
                if let mileagesList = resultset?.dictionaryValue[self.controller] {
                    for (_, mileage) in mileagesList {
                        var record = [String: String]()
                        for (key, value) in mileage {
                            record[key] = value.stringValue
                        }
                        if self.mileagesIds.contains(Int(record["id"]!)!) == false {
                            self.mileages[self.mileageIndex] = record
                            self.mileageIndex = self.mileageIndex + 1
                            self.mileagesIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.mileagePickerView.hidden = false
                    self.mileagePickerView.reloadAllComponents()
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mileages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if filterArray["mileage_name"] != nil && filterArray["mileage_name"] == mileages[row]!["name_"+appDefaultLanguage!] {
            mileagePickerView.selectRow(row, inComponent: component, animated: true)
        }
        return mileages[row]!["name_"+appDefaultLanguage!]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if let mileage = mileages[row] {
            filterArray["mileage"] = mileage["id"]!
            filterArray["mileage_name"] = mileage["name_"+appDefaultLanguage!]!
        }
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        filterArray["mileage"] = nil
        filterArray["mileage_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
}
