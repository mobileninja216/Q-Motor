//
//  ContactUsViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var sendMessage: UIButton!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "ContactUsViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("contactUsTtitle")
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.fullName.delegate = self;
        self.email.delegate = self;
        self.phoneNumber.delegate = self;
        self.message.delegate = self;

        let fullNamePaddingView = UIView(frame: CGRectMake(0, 0, 35, self.fullName.frame.height))
        fullName.leftView = fullNamePaddingView
        fullName.leftViewMode = UITextFieldViewMode.Always
        fullName.attributedPlaceholder = NSAttributedString(string: utility.__("fullName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let emailPaddingView = UIView(frame: CGRectMake(0, 0, 35, self.email.frame.height))
        email.leftView = emailPaddingView
        email.leftViewMode = UITextFieldViewMode.Always
        email.attributedPlaceholder = NSAttributedString(string: utility.__("email"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        let phoneNumberPaddingView = UIView(frame: CGRectMake(0, 0, 35, self.phoneNumber.frame.height))
        phoneNumber.leftView = phoneNumberPaddingView
        phoneNumber.leftViewMode = UITextFieldViewMode.Always
        phoneNumber.attributedPlaceholder = NSAttributedString(string: utility.__("phoneNumber"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        sendMessage.setTitle(utility.__("sendMessageButton"), forState: UIControlState.Normal)
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactUsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        sendMessage.hidden = true
        activityIndicator.hidden = false
        self.fullName.enabled = false
        self.email.enabled = false
        self.phoneNumber.enabled = false
        self.message.editable = false
        let parameters = ["fullname": fullName.text!, "email": email.text!, "phone": phoneNumber.text!, "message": message.text!]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("contactus").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        if (Int(error["code"]!)!==200) {
                            self.fullName.text = ""
                            self.email.text = ""
                            self.phoneNumber.text = ""
                            self.message.text = ""
                        }
                        self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                    }
                    self.sendMessage.hidden = false
                    self.activityIndicator.hidden = true
                    self.fullName.enabled = true
                    self.email.enabled = true
                    self.phoneNumber.enabled = true
                    self.message.editable = true
                }
            }
        }
    }
    
}
