//
//  SigninViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var newHereLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var textfieldsIcons: [UIImageView]!
    @IBOutlet var textfieldsForm: [UITextField]!
    @IBOutlet var signinButtons: [UIButton]!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var isKeyboardShown: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SigninViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("signinTitle")
        
        welcomeLabel.text = utility.__("welcomeLabel")
        signupButton.setTitle(utility.__("signupButton"), forState: UIControlState.Normal)
        newHereLabel.text = utility.__("newHereLabel")
        forgotPasswordButton.setTitle(utility.__("forgotPasswordButton"), forState: UIControlState.Normal)
        signinButton.setTitle(utility.__("signinButton"), forState: UIControlState.Normal)
        
        worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.userName.delegate = self;
        self.password.delegate = self;
        
        let userNamePaddingView = UIView(frame: CGRectMake(0, 0, 30, self.userName.frame.height))
        userName.leftView = userNamePaddingView
        userName.leftViewMode = UITextFieldViewMode.Always
        userName.attributedPlaceholder = NSAttributedString(string: utility.__("username"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let passwordPaddingView = UIView(frame: CGRectMake(0, 0, 30, self.password.frame.height))
        password.leftView = passwordPaddingView
        password.leftViewMode = UITextFieldViewMode.Always
        password.attributedPlaceholder = NSAttributedString(string: utility.__("password"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SigninViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SigninViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SigninViewController.dismissKeyboard))
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
            } else if Utility.DeviceType.IS_IPAD {
                marginBottom = 0
            }
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.scrollViewBottom.constant = marginBottom
                self.isKeyboardShown = true
                self.footerView.alpha = 0.0
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.scrollViewBottom.constant = 0
            self.isKeyboardShown = false
            self.footerView.alpha = 1.0
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signin(sender: UIButton) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        if userName.text != nil && password.text != nil {
            let parameters = ["user_id": userName.text!, "password": password.text!]
            self.activityIndicator?.hidden = false
            self.activityIndicator?.startAnimating()
            for textfield in self.textfieldsForm {
                textfield.hidden = true
            }
            for icon in textfieldsIcons {
                icon.hidden = true
            }
            for button in signinButtons {
                button.hidden = true
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("login").requestAndSave(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let user = resultset?.dictionaryValue["users"] {
                            for (key, value) in user {
                                profile[key] = value.stringValue
                            }
                        }
                        if resultset!["success"].boolValue == false {
                            for textfield in self.textfieldsForm {
                                textfield.hidden = false
                            }
                            for button in self.signinButtons {
                                button.hidden = false
                            }
                            for icon in self.textfieldsIcons {
                                icon.hidden = false
                            }
                            self.activityIndicator?.hidden = true
                            self.activityIndicator?.stopAnimating()
                            if let usernameError = resultset!["message"].dictionary {
                                if let userMessage = usernameError["user_id"]?.array![0].string {
                                    self.utility.showAlert(self, alertTitle: self.utility.__("error"), alertMessage: userMessage, style: "warning")
                                } else if let passwordMessage = usernameError["password"]?.array![0].string {
                                    self.utility.showAlert(self, alertTitle: self.utility.__("error"), alertMessage: passwordMessage, style: "warning")
                                }
                            } else if let message = resultset!["message"].array![0].string {
                                self.utility.showAlert(self, alertTitle: self.utility.__("error"), alertMessage: message, style: "error")
                            }
                        } else {
                            if let accessToken = resultset!["accessToken"].string {
                                preference!.setValue(accessToken, forKey: "accessToken")
                                preference!.synchronize()
                            }
                            self.performSegueWithIdentifier("profile", sender: nil)
                        }
                    }
                }
            }
        } else {
            self.utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("emptyFields"))
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profile" {
            let navigationController = segue.destinationViewController as! UINavigationController
            _ = navigationController.viewControllers.first as! MyAccountViewController
        }
    }
    
}
