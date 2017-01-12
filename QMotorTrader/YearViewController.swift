//
//  YearViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/9/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class YearViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yearPickerView: UIPickerView!

    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var years = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var controller = "year"
    var hasMore: Bool = false
    var isReady: Bool = true
    var yearsIds: [Int] = [Int]()
    var yearIndex: Int = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "YearViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.navigationItem.title = utility.__("yearTitle")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nextCursor = 1
        if self.utility.isConnectedToNetwork() {
            getOnlineYears()
        } else {
            getOfflineYears()
        }
        hasMore = true
    }
    
    func getOfflineYears() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.years = self.worker.select(Worker.Entities.YEAR, whereCondition: nil, sortBy: "year_en", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.hidden = true
                self.yearPickerView.hidden = false
                self.yearPickerView.reloadAllComponents()
            }
        }
    }
    
    func getOnlineYears() {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        self.nextCursor = 1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("filter?act=\(self.controller)&sortYear_en=desc&rowCount=\(self.limit)&page=1").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.years[0] = ["id": "0", "year_en": "", "year_ar": ""]
                if let yearsList = resultset?.dictionaryValue[self.controller] {
                    for (_, year) in yearsList {
                        var record = [String: String]()
                        for (key, value) in year {
                            record[key] = value.stringValue
                        }
                        if self.yearsIds.contains(Int(record["id"]!)!) == false {
                            self.yearIndex = self.yearIndex + 1
                            self.years[self.yearIndex] = record
                            self.yearsIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.yearPickerView.hidden = false
                    self.yearPickerView.reloadAllComponents()
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if filterArray["year_name"] != nil && filterArray["year_name"] == years[row]!["year_en"] {
            yearPickerView.selectRow(row, inComponent: component, animated: true)
        }
        return years[row]!["year_"+appDefaultLanguage!]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if let year = years[row] {
            filterArray["year_id"] = year["id"]!
            filterArray["year_name"] = year["year_"+appDefaultLanguage!]!
        }
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        filterArray["year_id"] = nil
        filterArray["year_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
    
}
