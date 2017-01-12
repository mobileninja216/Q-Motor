//
//  AddNumberPlatesViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class AddNumberPlatesViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var plateNumber: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var confrimNumber: UIButton!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "AddNumberPlatesViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        let plateNumberPaddingView = UIView(frame: CGRectMake(0, 0, 35, self.plateNumber.frame.height))
        plateNumber.leftView = plateNumberPaddingView
        plateNumber.leftViewMode = UITextFieldViewMode.Always
        plateNumber.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("plateNumber", comment:"Plate Number"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let pricePaddingView = UIView(frame: CGRectMake(0, 0, 35, self.price.frame.height))
        price.leftView = pricePaddingView
        price.leftViewMode = UITextFieldViewMode.Always
        price.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("price", comment:"Price"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])

        let phoneNumberPaddingView = UIView(frame: CGRectMake(0, 0, 35, self.phoneNumber.frame.height))
        phoneNumber.leftView = phoneNumberPaddingView
        phoneNumber.leftViewMode = UITextFieldViewMode.Always
        phoneNumber.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("phoneNumber", comment:"Phone Number"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func confirmNumber(sender: AnyObject) {
        confrimNumber.hidden = true
        activityIndicator.hidden = false
        self.plateNumber.enabled = false
        self.price.enabled = false
        self.phoneNumber.enabled = false
        let parameters = ["number_plates": plateNumber.text!, "price": price.text!, "phone": phoneNumber.text!]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("plates").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if (Int(error["code"]!)==200) {
                            self.plateNumber.text = ""
                            self.price.text = ""
                            self.phoneNumber.text = ""
                        }
                        self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                    }
                    self.confrimNumber.hidden = false
                    self.activityIndicator.hidden = true
                    self.plateNumber.enabled = true
                    self.phoneNumber.enabled = true
                    self.price.enabled = true
                }
            }
        }
    }
    
}
