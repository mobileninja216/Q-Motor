//
//  WebViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var utility: Utility = Utility.sharedInstance
    var pageUrl: String = "https://www.google.com/ncr"
    var pageName: String = "Google"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "WebViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = pageName
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)

        openPageView()
    }
    
    func openPageView() {
        self.webView.frame = self.view.bounds
        self.webView.scalesPageToFit = true
        webView.loadRequest(NSURLRequest(URL: NSURL(string: pageUrl)!))
    }

    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
        loader.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        loader.hidden = true
    }
}
