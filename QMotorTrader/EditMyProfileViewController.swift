//
//  EditMyProfileViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class EditMyProfileViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sellerType: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var secondName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var updateProfile: UIButton!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "EditMyProfileViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = utility.__("updateMyProfileTitle")
        updateProfile.setTitle(utility.__("updateMyProfileButton"), forState: UIControlState.Normal)
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("profile").request(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination, messageError) in
                if let error = messageError {
                    if Int(error["code"]!)! == 200 {
                        if let user = resultset!["profile"]!["user"].dictionary {
                            if user.count > 0 {
                                for (key, value) in user {
                                    profile[key] = value.stringValue
                                }
                            }
                        }
                    }
                } else {
                    profile = [:]
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                if profile.count > 0 {
                    self.firstName.text = profile["first_name"]
                    self.secondName.text = profile["last_name"]
                    self.phoneNumber.text = profile["phone"]
                    self.email.text = profile["email"]
                    self.sellerType.attributedPlaceholder = NSAttributedString(string: (Int(profile["user_t"]!) == 1 ? self.utility.__("individual") : self.utility.__("companies")), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
                }
            }
        }
        
        let sellerTypePaddingView = UIView(frame: CGRectMake(0, 0, 35, self.sellerType.frame.height))
        sellerType.leftView = sellerTypePaddingView
        sellerType.leftViewMode = UITextFieldViewMode.Always
        sellerType.attributedPlaceholder = NSAttributedString(string: utility.__("sellerType"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        sellerType.enabled = false
        
        let firstNamePaddingView = UIView(frame: CGRectMake(0, 0, 35, self.firstName.frame.height))
        firstName.leftView = firstNamePaddingView
        firstName.leftViewMode = UITextFieldViewMode.Always
        firstName.attributedPlaceholder = NSAttributedString(string: utility.__("firstName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let secondNamePaddingView = UIView(frame: CGRectMake(0, 0, 35, self.secondName.frame.height))
        secondName.leftView = secondNamePaddingView
        secondName.leftViewMode = UITextFieldViewMode.Always
        secondName.attributedPlaceholder = NSAttributedString(string: utility.__("secondName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let emailPaddingView = UIView(frame: CGRectMake(0, 0, 35, self.email.frame.height))
        email.leftView = emailPaddingView
        email.leftViewMode = UITextFieldViewMode.Always
        email.attributedPlaceholder = NSAttributedString(string: utility.__("email"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let phoneNumberPaddingView = UIView(frame: CGRectMake(0, 0, 35, self.phoneNumber.frame.height))
        phoneNumber.leftView = phoneNumberPaddingView
        phoneNumber.leftViewMode = UITextFieldViewMode.Always
        phoneNumber.attributedPlaceholder = NSAttributedString(string: utility.__("email"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func updateProfile(sender: AnyObject) {
        updateProfile.hidden = true
        activityIndicator.hidden = false
        self.sellerType.enabled = false
        self.firstName.enabled = false
        self.secondName.enabled = false
        self.email.enabled = false
        self.phoneNumber.enabled = false
        let parameters = ["first_name": firstName.text!, "last_name": secondName.text!, "phone": phoneNumber.text!, "email": email.text!]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("profile").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                    }
                    self.updateProfile.hidden = false
                    self.activityIndicator.hidden = true
                    self.sellerType.enabled = true
                    self.firstName.enabled = true
                    self.secondName.enabled = true
                    self.email.enabled = true
                    self.phoneNumber.enabled = true
                }
            }
        }
    }
    
}
