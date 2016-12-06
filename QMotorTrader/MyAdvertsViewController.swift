//
//  MyAdvertsViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class MyAdvertsViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var savedContainer: UIView!
    @IBOutlet weak var livedContainer: UIView!
    @IBOutlet weak var archivedContainer: UIView!

    var utility: Utility = Utility.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "MyAdvertsViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = utility.__("myAdvertsTitle")
        segmentedControl.setTitle(utility.__("savedAdvertText"), forSegmentAtIndex: 0)
        segmentedControl.setTitle(utility.__("livedvertText"), forSegmentAtIndex: 1)
        segmentedControl.setTitle(utility.__("archivedAdvertText"), forSegmentAtIndex: 2)
        
        var segAttributes: NSDictionary = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.segmentedControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
        segAttributes = [
            NSForegroundColorAttributeName: UIColor.blackColor()
        ]
        self.segmentedControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)

        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = Utility.ScreenSize.SCREEN_WIDTH - 50
            self.revealViewController().frontViewShadowRadius = 30
            self.revealViewController().frontViewShadowOffset = CGSizeMake(0.0, 2.5)
            self.revealViewController().frontViewShadowOpacity = 0.2
            menuButton.target = self.revealViewController()
            if sysDefaultLanguage == "en" {
                menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            } else {
                menuButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            }
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    @IBAction func changeView(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            savedContainer.hidden = false
            livedContainer.hidden = true
            archivedContainer.hidden = true
        case 1:
            savedContainer.hidden = true
            livedContainer.hidden = false
            archivedContainer.hidden = true
        case 2:
            savedContainer.hidden = true
            livedContainer.hidden = true
            archivedContainer.hidden = false
        default:
            break;
        }
    }
}
