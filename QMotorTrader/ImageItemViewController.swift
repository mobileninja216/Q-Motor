//
//  ImageItemViewController.swift
//  Q Motor
//
//  Created by StarMac on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import Haneke

class ImageItemViewController: UIViewController , UIScrollViewDelegate {
    
    var itemIndex: Int = 0
    var imageUrl: String = ""
    let scrollImg: UIScrollView = UIScrollView()

    @IBOutlet weak var imageViewContainer: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blackColor()
        
        imageUrl = imageUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        if let imageNSUrl = NSURL(string: imageUrl) {
            imageViewContainer.hnk_setImageFromURL(imageNSUrl)

            
            let vWidth = self.view.frame.width
            let vHeight = self.view.frame.height
            
            scrollImg.delegate = self
            scrollImg.frame = CGRectMake(0, 0, vWidth, vHeight)
         //   scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
            scrollImg.alwaysBounceVertical = false
            scrollImg.alwaysBounceHorizontal = false
            scrollImg.showsVerticalScrollIndicator = true
            scrollImg.flashScrollIndicators()
            
            scrollImg.minimumZoomScale = 1.0
            scrollImg.maximumZoomScale = 10.0
            
            self.view.addSubview(scrollImg)
            
           // imageViewContainer!.layer.cornerRadius = 11.0
            imageViewContainer!.clipsToBounds = false
            scrollImg.addSubview(imageViewContainer!)
            }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageViewContainer
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageViewContainer.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        
    }
    

    
    

}
