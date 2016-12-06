//
//  CameraGalleryViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import DKImagePickerController

class CameraGalleryViewController: UIViewController {
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var uploadedImages: UIButton!
    @IBOutlet weak var takePicture: UIButton!
    @IBOutlet weak var cameraRoll: UIButton!
    @IBOutlet weak var imageGallery: UICollectionView!
    
    var utility: Utility = Utility.sharedInstance
    var worker: Worker = Worker.sharedInstance
    var cells: [CameraGalleryCollectionViewCell?] = [nil, nil, nil, nil, nil, nil, nil, nil]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "CameraGalleryViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takePicture.setTitle(utility.__("takePicture"), forState: UIControlState.Normal)
        cameraRoll.setTitle(utility.__("cameraRoll"), forState: UIControlState.Normal)
        uploadedImages.setTitle(utility.__("uploadedImagesTitle"), forState: UIControlState.Normal)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        imageGallery.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gloabalAssets.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageBox", forIndexPath: indexPath) as! CameraGalleryCollectionViewCell
        let asset = gloabalAssets[indexPath.row]
        cell.imageView.image = asset.thumbnailImage
//        cell.imageLoader.hidden = true
//        cell.imageLoader.hidden = true
        cell.removeImage.tag = indexPath.row
        if cells[indexPath.row] == nil {
            self.cells[indexPath.row] = cell
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(collectionView.bounds)
        var columns = 2
        var height = 160
        if Utility.DeviceType.IS_IPAD {
            columns = 3
            height = 160
        } else if Utility.DeviceType.IS_IPHONE_FIVE || Utility.DeviceType.IS_IPHONE_FOUR_OR_LESS {
            columns = 1
            height = 160
        } else {
            columns = 2
            height = 120
        }
        let paddingCount = CGFloat(columns) + 1
        let cellPadding = 10
        let widthWithoutPadding = width - (CGFloat(cellPadding) * paddingCount)
        let cellWidth = widthWithoutPadding / CGFloat(columns)
        let cellHeight = CGFloat(height)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    @IBAction func viewCameraRoll(sender: AnyObject) {
        showImagePickerWithAssetType(.allPhotos, allowMultipleType: false, sourceType: .Photo)
    }
    
    @IBAction func viewCameraApp(sender: AnyObject) {
        showImagePickerWithAssetType(.allPhotos, allowMultipleType: false, sourceType: .Camera)
    }
    
    func showImagePickerWithAssetType(assetType: DKImagePickerControllerAssetType, allowMultipleType: Bool = true, sourceType: DKImagePickerControllerSourceType = [.Camera, .Photo]) {
        let pickerController = DKImagePickerController()
        pickerController.assetType = assetType
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.maxSelectableCount = 8 - gloabalAssets.count
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            if gloabalAssets.count >= 8 {
                gloabalAssets.removeFirst()
            }
            gloabalAssets += assets
            self.imageGallery?.reloadData()
        }
        self.presentViewController(pickerController, animated: true) {}
    }
    
    @IBAction func removeImage(sender: UIButton) {
        gloabalAssets.removeAtIndex(sender.tag)
        imageGallery.reloadData()
    }
}
