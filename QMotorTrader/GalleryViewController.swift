//
//  GalleryViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var pageViewController: UIPageViewController?
    var dissmisButton: UIButton?
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var carDetails = [Int: [String: String]]()
    let controller = "cars"
    let reuseIdentifier = "carImage"
    var cars = [Int: [String: String]]()
    var carImages = [Int: [String: String]]()
    var carSellingPoints = [Int: [String: String]]()
    var carId: Int = 0
    var carSellingPointIndex: Int = 0
    var carsImagesIds: [Int] = [Int]()
    var carIndex: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "GalleryViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dissmisButton = UIButton(frame: CGRectMake(15, 25, 30, 30))
        dissmisButton!.setTitle("X", forState: UIControlState.Normal)
        dissmisButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dissmisButton!.backgroundColor = UIColor.redColor()
        dissmisButton!.layer.borderColor = UIColor.whiteColor().CGColor
        dissmisButton!.layer.borderWidth = CGFloat(1.5)
        dissmisButton!.layer.cornerRadius = 15
        dissmisButton!.addTarget(self, action: #selector(GalleryViewController.dismissView(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(self.dissmisButton!)
        
        getOnlineCar()
    }

    func getOnlineCar() {
        if self.utility.isConnectedToNetwork() == false {
            utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("connectionless"), style: "warning")
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.worker.makeUrl("cars/\(self.carId)").requestAndSave(Worker.Method.GET, parameters: [:]) {
                (resultset, pagination) in
                let record = resultset!["cars"][0]
                for (_, carImage) in record["cars_image"] {
                    var image = [String: String]()
                    image["image"] = carImage["image"].stringValue
                    image["id"] = carImage["id"].stringValue
                    if self.carsImagesIds.contains(carImage["id"].int!) == false {
                        self.carImages[self.carIndex] = image
                        self.carIndex = self.carIndex + 1
                        self.carsImagesIds.append(carImage["id"].int!)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.createPageViewController()
                    self.view.addSubview(self.dissmisButton!)
                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        if carImages.count > 0 {
            let firstController = getItemController(0)
            let startingViewControllers: NSArray = [firstController!]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageItemViewController
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageItemViewController
        if itemController.itemIndex+1 < carImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> ImageItemViewController? {
        if itemIndex < carImages.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageItemController") as! ImageItemViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageUrl = carImages[itemIndex]!["image"]!
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return carImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    func dismissView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
