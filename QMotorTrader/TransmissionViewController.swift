//
//  TransmissionViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/11/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class TransmissionViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transmissionsPickerView: UIPickerView!
    
    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var transmissions = [Int: [String: String]]()
    let limit: Int = 30
    var nextCursor: Int = 1
    var controller = "transmission"
    var hasMore: Bool = false
    var isReady: Bool = true
    var transmissionsIds: [Int] = [Int]()
    var transmissionIndex: Int = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "TransmissionViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.navigationItem.title = utility.__("transTitle")
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
            self.transmissions = self.worker.select(Worker.Entities.TRANSMISSION, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.transmissionsPickerView.reloadAllComponents()
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
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortTransmission_name_\(appDefaultLanguage!)=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.transmissions[0] = ["id": "0", "transmission_name_en": "", "transmission_name_ar": ""]
                if let transmissionsList = resultset?.dictionaryValue[self.controller] {
                    for (_, transmission) in transmissionsList {
                        var record = [String: String]()
                        for (key, value) in transmission {
                            record[key] = value.stringValue
                        }
                        if self.transmissionsIds.contains(Int(record["id"]!)!) == false {
                            self.transmissionIndex = self.transmissionIndex + 1
                            self.transmissions[self.transmissionIndex] = record
                            self.transmissionsIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.transmissionsPickerView.hidden = false
                    self.transmissionsPickerView.reloadAllComponents()
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return transmissions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if filterArray["transmission_name"] != nil && filterArray["transmission_name"] == transmissions[row]!["transmission_name_"+appDefaultLanguage!] {
            transmissionsPickerView.selectRow(row, inComponent: component, animated: true)
        }
        return transmissions[row]!["transmission_name_"+appDefaultLanguage!]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if let transmission = transmissions[row] {
            filterArray["trans_id"] = transmission["id"]!
            filterArray["transmission_name"] = transmission["transmission_name_"+appDefaultLanguage!]!
        }
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        filterArray["trans_id"] = nil
        filterArray["transmission_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
}
