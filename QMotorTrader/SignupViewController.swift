//
//  SignupViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(backgroundColor!), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(imageWithColor(tintColor!), forState: .Selected, barMetrics: .Default)
        setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor);
        CGContextFillRect(context!, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var textfieldsForm: [UITextField]!
    @IBOutlet var textfieldsIcons: [UIImageView]!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var companiesView: UIView!
    @IBOutlet weak var individualView: UIView!
    @IBOutlet weak var userFirstName: UITextField!
    @IBOutlet weak var userLastName: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
    @IBOutlet weak var segmetedControl: UISegmentedControl!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var isKeyboardShown: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SignupViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.segmetedControl.layer.cornerRadius = 20.0;
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
        
        self.userFirstName.delegate = self;
        self.userLastName.delegate = self;
        self.userPhoneNumber.delegate = self;
        
        let userFirstNamePaddingView = UIView(frame: CGRectMake(0, 0, 30, self.userFirstName.frame.height))
        userFirstName.leftView = userFirstNamePaddingView
        userFirstName.leftViewMode = UITextFieldViewMode.Always
        userFirstName.attributedPlaceholder = NSAttributedString(string: utility.__("firstName"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let userLastNamePaddingView = UIView(frame: CGRectMake(0, 0, 30, self.userLastName.frame.height))
        userLastName.leftView = userLastNamePaddingView
        userLastName.leftViewMode = UITextFieldViewMode.Always
        userLastName.attributedPlaceholder = NSAttributedString(string: utility.__("lastName"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let userPhoneNumberPaddingView = UIView(frame: CGRectMake(0, 0, 30, self.userPhoneNumber.frame.height))
        userPhoneNumber.leftView = userPhoneNumberPaddingView
        userPhoneNumber.leftViewMode = UITextFieldViewMode.Always
        userPhoneNumber.attributedPlaceholder = NSAttributedString(string: utility.__("phoneNumber"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        welcomeLabel.text = utility.__("welcomeLabel")
        segmetedControl.setTitle(utility.__("individual"), forSegmentAtIndex: 0)
        segmetedControl.setTitle(utility.__("companies"), forSegmentAtIndex: 1)
        registerButton.setAttributedTitle(NSAttributedString(string: utility.__("registerButton"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: UIControlState.Normal)
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignupViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignupViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if isKeyboardShown == false {
            var info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            var marginBottom = keyboardFrame.size.height
            if Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
                marginBottom = keyboardFrame.size.height + 30
            } else if Utility.DeviceType.IS_IPHONE_FIVE {
                marginBottom = keyboardFrame.size.height
            } else if Utility.DeviceType.IS_IPAD {
                marginBottom = 0
            }
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.scrollViewBottom.constant = marginBottom
                self.isKeyboardShown = true
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.scrollViewBottom.constant = 0
            self.isKeyboardShown = false
        })
    }
 
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func changeView(sender: UISegmentedControl) {
        switch segmetedControl.selectedSegmentIndex {
        case 0:
            individualView.hidden = false
            companiesView.hidden = true
        case 1:
            individualView.hidden = true
            companiesView.hidden = false
        default:
            break;
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return false
    }
    
    @IBAction func register(sender: UIButton) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        let parameters = ["first_name": userFirstName.text!, "last_name": userLastName.text!, "phone": userPhoneNumber.text!]
        self.activityIndicator?.hidden = false
        self.activityIndicator?.startAnimating()
        registerButton.hidden = true
        for textfield in self.textfieldsForm {
            textfield.hidden = true
        }
        segmetedControl.hidden = true
        for icon in textfieldsIcons {
            icon.hidden = true
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("register").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["code"]! == "200" ? self.utility.__("registerDone") : error["message"]!, style: error["code"]! == "200" ? "success" : "warning")
                        if error["code"]! == "200" {
                            self.performSegueWithIdentifier("signin", sender: nil)
                        }
                    }
                    for textfield in self.textfieldsForm {
                        textfield.hidden = false
                    }
                    self.registerButton.hidden = false
                    for icon in self.textfieldsIcons {
                        icon.hidden = false
                    }
                    self.segmetedControl.hidden = false
                    self.activityIndicator?.hidden = true
                    self.activityIndicator?.stopAnimating()
                }
            }
        }
    }
    
    
}

