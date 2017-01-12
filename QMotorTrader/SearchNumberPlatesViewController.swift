//
//  SearchNumberPlatesViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class SearchNumberPlatesViewController: UIViewController {

    @IBOutlet weak var numberPlate: UITextField!
    var utility = Utility.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SearchNumberPlatesViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let numberPlatePaddingView = UIView(frame: CGRectMake(0, 0, 30, self.numberPlate.frame.height))
        numberPlate.leftView = numberPlatePaddingView
        numberPlate.leftViewMode = UITextFieldViewMode.Always
        numberPlate.attributedPlaceholder = NSAttributedString(string: utility.__("enterPlateNumber"), attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchNumberPlate" {
            let numberPlatesViewController = segue.destinationViewController as! NumberPlatesViewController
            numberPlatesViewController.numberPlateId = Int(numberPlate.text!)!
        }
    }

}
