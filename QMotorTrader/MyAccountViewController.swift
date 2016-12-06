//
//  MyAccountViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 9/2/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyAccountViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myAdvertsButton: UIButton!
    @IBOutlet weak var myNumberPlatesButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var myGarageButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var fullName: UILabel!
    var username: UITextField!
    var password: UITextField!
    var firstName: UITextField!
    var lastName: UITextField!
    var phoneNumber: UITextField!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MyAccountViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("myAccountTitle")
        myAdvertsButton.setTitle(utility.__("myAdvertsButton"), forState: UIControlState.Normal)
        myNumberPlatesButton.setTitle(utility.__("myNumberPlatesButton"), forState: UIControlState.Normal)
        myProfileButton.setTitle(utility.__("myProfileButton"), forState: UIControlState.Normal)
        myGarageButton.setTitle(utility.__("myGarageButton"), forState: UIControlState.Normal)
        
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.addAttribute(NSKernAttributeName, value:   CGFloat(2.5), range: NSRange(location: 0, length: attributedString.length))
        userEmail.attributedText = attributedString
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        
        viewProfile()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func viewProfile() {
        if self.utility.isConnectedToNetwork() {
            worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("profile").request(Worker.Method.GET, parameters: [:]) {
                    (resultset, pagination, messageError) in
                    if Int(messageError!["code"]!)! == 200 {
                        if let user = resultset!["profile"]!["user"].dictionary {
                            if user.count > 0 {
                                for (key, value) in user {
                                    profile[key] = value.stringValue
                                }
                            }
                        }
                    } else if Int(messageError!["code"]!)! == 401 {
                        self.containerView.hidden = true
                        self.activityIndicator.hidden = false
                        self.showSignInAlertAction(nil)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if profile.count > 0 {
                        self.userEmail.text = profile["email"]
                        self.fullName.text = profile["fullname_en"]?.capitalizedString
                        self.containerView.hidden = false
                        self.activityIndicator.hidden = true
                    }
                }
            }
        } else {
            let homeController = self.storyboard!.instantiateViewControllerWithIdentifier("homeView") as! HomeViewController
            self.navigationController?.pushViewController(homeController, animated: true)
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
        }
    }
    
    func showSignUpAlertAction(alert: UIAlertAction!) {
        let alertController = UIAlertController(title: self.utility.__("signupAlertTitle"), message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("firstName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.firstName = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("lastName"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.lastName = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("phoneNumber"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.phoneNumber = textField
        }
        alertController.addAction(UIAlertAction(title: self.utility.__("signupButton"), style: UIAlertActionStyle.Default, handler: signup))
        //        alertController.addAction(UIAlertAction(title: self.utility.__("signinButton"), style: UIAlertActionStyle.Default, handler: showSignInAlertAction))
        alertController.addAction(UIAlertAction(title: self.utility.__("cancleButton"), style: UIAlertActionStyle.Cancel, handler: goToHomeView))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showSignInAlertAction(alert: UIAlertAction!) {
        let alertController = UIAlertController(title: self.utility.__("signinAlertTitle"), message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("username"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.username = textField
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.attributedPlaceholder = NSAttributedString(string: self.utility.__("password"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
            textField.secureTextEntry = true
            var frameRect: CGRect = textField.frame
            frameRect.size.height = 180
            textField.frame = frameRect
            textField.borderStyle = UITextBorderStyle.RoundedRect
            self.password = textField
        }
        alertController.addAction(UIAlertAction(title: self.utility.__("signinButton"), style: UIAlertActionStyle.Default, handler: signin))
        alertController.addAction(UIAlertAction(title: self.utility.__("signupButton"), style: UIAlertActionStyle.Default, handler: showSignUpAlertAction))
        alertController.addAction(UIAlertAction(title: self.utility.__("cancleButton"), style: UIAlertActionStyle.Cancel, handler: goToHomeView))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func goToHomeView(alert: UIAlertAction) {
        let homeController = self.storyboard!.instantiateViewControllerWithIdentifier("homeView") as! HomeViewController
        self.navigationController?.pushViewController(homeController, animated: true)
    }
    
    func signin(alert: UIAlertAction!) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if self.username.text != nil && self.password.text != nil {
                let parameters = ["user_id": self.username.text!, "password": self.password.text!]
                self.worker.makeUrl("login").requestAndSave(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination) -> Void in
                    if let user = resultset?.dictionaryValue["users"] {
                        for (key, value) in user {
                            profile[key] = value.stringValue
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        if resultset?.count <= 0 {
                            self.showSignInAlertAction(nil)
                        } else {
                            if let accessToken = resultset!["accessToken"].string {
                                preference!.setValue(accessToken, forKey: "accessToken")
                                preference!.synchronize()
                            }
                            self.viewProfile()
                        }
                    }
                }
            } else {
                self.utility.showAlert(self, alertTitle: self.utility.__("warning"), alertMessage: self.utility.__("emptyFields"))
                self.showSignInAlertAction(nil)
            }
        }
    }
    
    func signup(alert: UIAlertAction!) {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        let parameters = ["first_name": firstName.text!, "last_name": lastName.text!, "phone": phoneNumber.text!]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("register").request(Worker.Method.POST, parameters: parameters) {
                (resultset, pagination, messageError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if let error = messageError {
                        self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                        self.showSignUpAlertAction(nil)
                    } else {
                        self.showSignInAlertAction(nil)
                    }
                }
            }
        }
    }
}
