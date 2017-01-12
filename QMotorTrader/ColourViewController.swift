//
//  ColourViewController.swift
//  Q Motor
//
//  Created by StarMac on 9/11/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class ColourViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var coloursPickerView: UIPickerView!
    
    var worker: Worker = Worker.sharedInstance
    var utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var colours = [Int: [String: String]]()
    let limit: Int = 300
    var nextCursor: Int = 1
    var controller = "colour"
    var hasMore: Bool = false
    var isReady: Bool = true
    var coloursIds: [Int] = [Int]()
    var colourIndex: Int = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "ColourViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.navigationItem.title = utility.__("colourTitle")
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
            self.colours = self.worker.select(Worker.Entities.COLOUR, whereCondition: nil, sortBy: "id", isAscending: false, cursor: self.nextCursor, limit: self.limit, indexedBy: "index")!
            self.nextCursor = self.nextCursor + 1
            dispatch_async(dispatch_get_main_queue()) {
                self.coloursPickerView.reloadAllComponents()
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
            self.worker.makeUrl("filter?act=\(self.controller)&rowCount=\(self.limit)&page=1&sortColor_name_\(appDefaultLanguage!)=asc").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                self.colours[0] = ["id": "0", "color_name_en": "", "color_name_ar": ""]
                if let coloursList = resultset?.dictionaryValue[self.controller] {
                    for (_, colour) in coloursList {
                        var record = [String: String]()
                        for (key, value) in colour {
                            record[key] = value.stringValue
                        }
                        if self.coloursIds.contains(Int(record["id"]!)!) == false {
                            self.colourIndex = self.colourIndex + 1
                            self.colours[self.colourIndex] = record
                            self.coloursIds.append(Int(record["id"]!)!)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.nextCursor = 2
                    self.activityIndicator.hidden = true
                    self.coloursPickerView.hidden = false
                    self.coloursPickerView.reloadAllComponents()
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colours.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if filterArray["colour_name"] != nil && filterArray["colour_name"] == colours[row]!["color_name_"+appDefaultLanguage!] {
            coloursPickerView.selectRow(row, inComponent: component, animated: true)
        }
        return colours[row]!["color_name_"+appDefaultLanguage!]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if let colour = colours[row] {
            filterArray["colour_id"] = colour["id"]!
            filterArray["colour_name"] = colour["color_name_"+appDefaultLanguage!]!
        }
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func reset(sender: AnyObject) {
        filterArray["colour_id"] = nil
        filterArray["colour_name"] = nil
        navigationController?.popViewControllerAnimated(true)
    }
}
