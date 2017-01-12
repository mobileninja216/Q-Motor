//
//  BodytypeViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/11/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class BodytypeViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bodytypiesPickerView: UIPickerView!
    
    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var bodytypies = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var controller = "bodytype"
    var hasMore: Bool = false
    var isReady: Bool = true
    var bodytypiesIds: [Int] = [Int]()
    var bodytypeIndex: Int = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "BodytypeViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.navigationItem.title = utility.__("bodyTypeTitle")
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
            self.bodytypies = self.worker.select(Worker.Entities.BODYTYPE, whereCondition: nil, sortBy: "id", isAscending: true, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.bodytypiesPickerView.reloadAllComponents()
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
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortBodytype_name_\(appDefaultLanguage!)=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.bodytypies[0] = ["id": "0", "bodytype_name_en": "", "bodytype_name_ar": ""]
                if let bodytypiesList = resultset?.dictionaryValue[self.controller] {
                    for (_, bodytype) in bodytypiesList {
                        var record = [String: String]()
                        for (key, value) in bodytype {
                            record[key] = value.stringValue
                        }
                        if self.bodytypiesIds.contains(Int(record["id"]!)!) == false {
                            self.bodytypies[self.bodytypeIndex] = record
                            self.bodytypeIndex = self.bodytypeIndex + 1
                            self.bodytypiesIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.bodytypiesPickerView.hidden = false
                    self.bodytypiesPickerView.reloadAllComponents()
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bodytypies.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if filterArray["bodytype_name"] != nil && filterArray["bodytype_name"] == bodytypies[row]!["bodytype_name_"+appDefaultLanguage!] {
            bodytypiesPickerView.selectRow(row, inComponent: component, animated: true)
        }
        return bodytypies[row]!["bodytype_name_"+appDefaultLanguage!]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if let bodytype = bodytypies[row] {
            filterArray["body_id"] = bodytype["id"]!
            filterArray["bodytype_name"] = bodytype["bodytype_name_"+appDefaultLanguage!]!
        }
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        filterArray["body_id"] = nil
        filterArray["bodytype_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
}
