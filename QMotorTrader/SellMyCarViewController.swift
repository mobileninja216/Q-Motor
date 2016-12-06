//
//  SellMyCarViewController.swift
//  Minao
//
//  Created by Mahmood Nassar - (+970598197338) on 8/29/15.
//  Copyright (c) 2015 Minao. All rights reserved.
//

import UIKit
//import DKImagePickerController

var selectedPackageId: Int = 0
var selectedPackageDuration: Int = 0
var carDetails: [String: String] = [:]
var newCarAdvertID: Int = 0
var gloabalAssets: [DKAsset] = [DKAsset]()

class SellMyCarViewController: UIViewController {
    
    @IBOutlet weak var stepsBar: UIView!
    @IBOutlet weak var firstStepButton: UIView!
    @IBOutlet weak var secondStepButton: UIView!
    @IBOutlet weak var uploadProgress: UIProgressView!
    @IBOutlet weak var progressActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadLoader: UIActivityIndicatorView!
    @IBOutlet weak var fifthLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var fifthBullet: UIView!
    @IBOutlet weak var fourthBullet: UIView!
    @IBOutlet weak var thirdBullet: UIView!
    @IBOutlet weak var secondBullet: UIView!
    @IBOutlet weak var firstBullet: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var packageContainer: UIView!
    @IBOutlet weak var confirmContainer: UIView!
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var cameraRollContainer: UIView!
    @IBOutlet weak var vehicleDetailsContainer: UIView!
    @IBOutlet weak var thanksContainer: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var saveAndContinue: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var uploadImages: UIButton!
    @IBOutlet weak var toolbarView: UIView!
    
    var username: UITextField!
    var password: UITextField!
    var firstName: UITextField!
    var lastName: UITextField!
    var phoneNumber: UITextField!
    
    var worker: Worker = Worker.sharedInstance
    var utility: Utility = Utility.sharedInstance
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var nextStep = 2
    var selectedAdvertId: Int = 0
    var carPrice: String = ""
    var dealerPhone1: String = ""
    var dealerPhone2: String = ""
    var carMileage: String = ""
    var carSellingpoint:[String] = []
    var completedUploadedImages: Int = 0
    var lastStep = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let name = "SellMyCarViewController"
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.worker.setUp(context: managedObjectContext!, domain: "qmotor.com")
        
        self.title = utility.__("sellMyCarTitle")
        
        saveAndContinue.setTitle(utility.__("saveAndContinue"), forState: UIControlState.Normal)
        saveButton.setTitle(utility.__("saveButton"), forState: UIControlState.Normal)
        firstLabel.text = utility.__("packageLabel")
        secondLabel.text = utility.__("vechilceDetailsLabel")
        thirdLabel.text = utility.__("uploadImagesLabel")
        fourthLabel.text = utility.__("previewLabel")
        fifthLabel.text = utility.__("confirmLabel")
        uploadImages.setTitle(utility.__("uploadImagesButton"), forState: UIControlState.Normal)
        
        utility.showMenu(self.revealViewController(), menuButton: menuButton, view: self.view)
        
        viewFirstController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if gloabalAssets.count > 0 {
            uploadImages.hidden = false
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first! as UITouch
        let buttonView = touch.view! as UIView
        if !isUploading {
            if buttonView.tag > 0 && buttonView.tag <= lastStep {
                nextStep = buttonView.tag
                self.chooseView(buttonView.tag)
            }
        }
        self.view.endEditing(true)
    }
    
    func viewFirstController() {
        selectedPackageId = 0
        
        if profile.isEmpty {
            self.saveAndContinue.hidden = true
            self.showSignInAlertAction(nil)
        } else {
            self.saveAndContinue.hidden = false
        }
        
        if self.selectedAdvertId > 0 {
            newCarAdvertID = self.selectedAdvertId
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("sellcar?steps=6&cars_id=\(self.selectedAdvertId)").request(Worker.Method.GET) {
                    (resultset, pagination, messageError) -> Void in
                    var expired_date: String?
                    if Int(messageError!["code"]!)==401 {
                        self.saveAndContinue.hidden = true
                        self.saveButton.hidden = true
                        self.showSignInAlertAction(nil)
                    } else if Int(messageError!["code"]!)==200 {
                        if let par = resultset!["par"]?.dictionary {
                            self.nextStep = par["stepsOrg"]!.intValue
                            self.lastStep = par["steps"]!.intValue
                            selectedPackageId = par["pkg_id"]!.intValue
                        }
                        if let record = resultset!["sellcar_dt"]![0].dictionary {
                            if let sellingpoint = record["cars_sellingpoint"]!.array {
                                for (value) in sellingpoint {
                                    self.carSellingpoint.append(value["id"].stringValue)
                                }
                            }
                            filterArray["make_id"] = record["make_id"]!.stringValue
                            if let make = self.worker.findById(Worker.Entities.MAKE, id: record["make_id"]!.intValue) {
                                filterArray["make_name"] = make["make_name_"+appDefaultLanguage!]
                            }
                            if let model_id = record["model_id"]?.stringValue {
                                filterArray["model_id"] = model_id
                                filterArray["model_name"] = record["model_name_"+appDefaultLanguage!]?.stringValue
                            }
                            let trimId = record["trim_id"]!.int
                            if let trim_id = trimId {
                                filterArray["trim_id"] = String(trim_id)
                                filterArray["trim_name"] = record["trim_name_"+appDefaultLanguage!]?.stringValue
                            }
                            let yearId = record["year_id"]!.int
                            if let year_id = yearId {
                                filterArray["year_id"] = String(year_id)
                                filterArray["year_name"] = record["year_"+appDefaultLanguage!]?.stringValue
                            } else {
                                filterArray["trim_id"] = nil
                            }
                            self.carMileage = record["mileage"]!.stringValue
                            self.dealerPhone1 = record["phone1"]!.stringValue
                            self.dealerPhone2 = record["phone2"]!.stringValue
                            self.carPrice = record["price"]!.stringValue
                            if let body_id = record["body_id"]?.stringValue {
                                filterArray["body_id"] = body_id
                                filterArray["bodytype_name"] = record["bodytype_name_"+appDefaultLanguage!]?.stringValue
                            }
                            if let trans_id = record["trans_id"]?.stringValue {
                                filterArray["trans_id"] = trans_id
                                filterArray["transmission_name"] = record["transmission_name_"+appDefaultLanguage!]?.stringValue
                            }
                            if let colour_id = record["colour_id"]?.stringValue {
                                filterArray["colour_id"] = colour_id
                                filterArray["colour_name"] = record["color_name_"+appDefaultLanguage!]?.stringValue
                            }
                            if let expiredDate = record["exp_date"]?.stringValue {
                                expired_date = expiredDate
                            }
                        }
                        self.saveAndContinue.hidden = false
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.nextStep == 6 && expired_date != nil {
                            self.nextStep = 2
                            self.saveButton.hidden = false
                        }
                        self.chooseView(self.nextStep, isEditable: true)
                    }
                }
            }
        } else {
            self.chooseView(2)
            lastStep = 2
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func chooseView(currentStep: Int, isEditable: Bool = false) {
        
        if currentStep == 2 {
            let packageController = self.childViewControllers[0] as! PackageViewController
            packageController.getOnlinePackages()
        } else if currentStep == 3 {
            let addCarDetailsController = self.childViewControllers[1] as! AddCarDetailsViewController
            addCarDetailsController.getSellingPoints(self.carSellingpoint)
            addCarDetailsController.setupUI()
            addCarDetailsController.mileageTextField.text = self.carMileage
            addCarDetailsController.phone1TextField.text = self.dealerPhone1
            addCarDetailsController.phone2TextField.text = self.dealerPhone2
            addCarDetailsController.carPriceTextField.text = self.carPrice
        }
        packageContainer.hidden = currentStep==2 ? false : true
        vehicleDetailsContainer.hidden = currentStep==3 ? false : true
        cameraRollContainer.hidden = currentStep==4 ? false : true
        previewContainer.hidden = currentStep==5 ? false : true
        confirmContainer.hidden = currentStep==6 ? false : true
        thanksContainer.hidden = true

        self.uploadImages.hidden = true
        
        if selectedAdvertId > 0 {
            self.saveAndContinue.hidden = false
            self.saveButton.hidden = false
        } else {
            self.saveAndContinue.hidden = false
            self.saveButton.hidden = true
        }
        
        firstLabel.hidden = currentStep==2 ? false : true
        secondLabel.hidden = currentStep==3 ? false : true
        thirdLabel.hidden = currentStep==4 ? false : true
        fourthLabel.hidden = currentStep==5 ? false : true
        fifthLabel.hidden = currentStep==6 ? false : true
        if currentStep==2 {
            print("currentStep=2")
            self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.secondBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.progressBar.setProgress(0.0, animated: true)
        } else if currentStep==3 {
            print("currentStep=3")
            self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.secondBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
            self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.progressBar.setProgress(0.25, animated: true)
        } else if currentStep==4 {
            print("currentStep=4")
            if gloabalAssets.count > 0 {
                self.uploadImages.hidden = false
            }
            let cameraGalleryController = self.childViewControllers[2] as! CameraGalleryViewController
            cameraGalleryController.imageGallery.reloadData()
            self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
            self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.progressBar.setProgress(0.5, animated: true)
        } else if currentStep==5 {
            print("currentStep=5")
            self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
            self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0xffffff)
            self.progressBar.setProgress(0.75, animated: true)
        } else if currentStep==6 {
            print("currentStep=6")
            self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
            self.progressBar.setProgress(1.0, animated: true)
        } else if currentStep==7 {
            print("currentStep=7")
            self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
            self.progressBar.setProgress(1.0, animated: true)
            thanksContainer.hidden = false
        }
        if currentStep == 5 {
            print("currentStep=5")
            self.saveAndContinue.hidden = true
            self.saveButton.hidden = true
        } else {
            if selectedAdvertId > 0 {
                self.saveAndContinue.hidden = false
                self.saveButton.hidden = false
            } else {
                self.saveAndContinue.hidden = false
                self.saveButton.hidden = true
            }
        }
        if currentStep == 5 {
            print("currentStep=5")
            let previewController = self.childViewControllers[3] as! PreviewViewController
            previewController.getOnlineAdvert(currentStep)
        }
        if currentStep == 6 {
            print("currentStep=6")
            let confirmController = self.childViewControllers[4] as! ConfirmViewController
            confirmController.getOnlineAdvert(currentStep)
            self.saveButton.hidden = true
            self.saveAndContinue.hidden = false
            self.saveAndContinue.setTitle(self.utility.__("completeTheCheckout"), forState: UIControlState.Normal)
        } else {
            self.saveAndContinue.setTitle(self.utility.__("saveAndContinue"), forState: UIControlState.Normal)
        }
        if currentStep == 7 {
            print("currentStep=7")
            self.toolbarView.hidden = true
            self.nextStep = 2
        }
    }
    
    var isUploading: Bool = false
    @IBAction func uploadImages(sender: UIButton) {
        self.uploadImages.hidden = true
        self.saveButton.hidden = true
        self.saveAndContinue.hidden = true
        if self.nextStep == 4 {
            if gloabalAssets.count > 0 {
                uploadLoader.hidden = false
                let cameraController = self.childViewControllers[2] as! CameraGalleryViewController
                let cells = cameraController.cells
                for cell in cells {
                    if cell != nil {
                        cell?.removeImage.hidden = true
                    }
                }
                cameraController.cameraRoll.enabled = false
                cameraController.takePicture.enabled = false
                cameraController.uploadedImages.enabled = false
                cameraController.loaderView.hidden = false
                isUploading = true
                print("Upload Images")
                uploadImage(gloabalAssets, index: 0) {
                    cameraController.cameraRoll.enabled = true
                    cameraController.takePicture.enabled = true
                    cameraController.uploadedImages.enabled = true
                    gloabalAssets = [DKAsset]()
                    cameraController.imageGallery.reloadData()
                    self.uploadLoader.hidden = true
                    self.saveAndContinue.hidden = false
                    self.isUploading = false
                    cameraController.loaderView.hidden = true
                    if self.selectedAdvertId > 0 {
                        self.saveButton.hidden = false
                    }
                }
            }
        }
    }
    
    func uploadImage(var assets: [DKAsset], var index: Int = 0, onCompleted: () -> Void) {
        self.uploadProgress.hidden = false
        if index <= 7 && assets.count > 0 {
            let asset = assets.removeFirst()
            self.worker.makeUrl("cars/upload?cars_id=\(newCarAdvertID)").upload(asset.fullResolutionImage!) {
                response, error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.uploadProgress.setProgress(Float(index/gloabalAssets.count), animated: true)
                    index = index + 1
                    self.uploadImage(assets, index: index, onCompleted: onCompleted)
                }
            }
        } else {
            onCompleted()
        }
    }
    
    @IBAction func saveAndContinue(sender: UIButton) {
        self.saveAndContinue.hidden = true
        self.saveButton.hidden = true
        self.progressActivityIndicator.hidden = false
        var parameters: [String : String] = [:]
        // TODO send save and exit request parameter  [last=1]
        if self.nextStep == 2 {
            parameters = ["pkg_id":String(selectedPackageId)]
            self.vehicleDetailsContainer.hidden = true
            self.cameraRollContainer.hidden = true
            self.previewContainer.hidden = true
            self.thanksContainer.hidden = true
            var urlQuery: String = ""
            if sender.tag == 1 {
                parameters["last"] = "1"
            }
            if self.selectedAdvertId > 0 {
                parameters["steps"] = String(self.nextStep)
                parameters["_method"] = "put"
                urlQuery = "sellcar/\(newCarAdvertID)"
            } else {
                urlQuery = "sellcar?steps=\(self.nextStep)"
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl(urlQuery).request(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination, messageError) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.progressActivityIndicator.hidden = true
                        self.saveAndContinue.hidden = false
                        if self.selectedAdvertId > 0 {
                            self.saveButton.hidden = false
                        }
                        if let error = messageError {
                            if (Int(error["code"]!)==200) {
                                self.nextStep = resultset!["par"]!["steps"].int!
                                newCarAdvertID = Int(resultset!["par"]!["cars_id"].intValue)
                                self.lastStep = self.nextStep
                                self.progressBar.setProgress(0.25, animated: true)
                                self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                self.secondBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
                                self.packageContainer.hidden = true
                                self.vehicleDetailsContainer.hidden = false
                                self.cameraRollContainer.hidden = true
                                self.previewContainer.hidden = true
                                self.confirmContainer.hidden = true
                                self.thanksContainer.hidden = true
                                self.firstLabel.hidden = true
                                self.secondLabel.hidden = false
                                self.thirdLabel.hidden = true
                                self.fourthLabel.hidden = true
                                if self.nextStep == 7 {
                                    let thanksController = self.childViewControllers[5] as! ThanksViewController
                                    thanksController.viewThanksMessage()
                                    self.toolbarView.hidden = true
                                    self.packageContainer.hidden = true
                                    self.vehicleDetailsContainer.hidden = true
                                    self.cameraRollContainer.hidden = true
                                    self.previewContainer.hidden = true
                                    self.confirmContainer.hidden = true
                                    self.thanksContainer.hidden = false
                                    self.stepsBar.hidden = true
                                    self.uploadProgress.hidden = true
                                    self.toolbarView.hidden = true
                                } else {
                                    if self.selectedAdvertId == 0 {
                                        if self.nextStep==3 {
                                            let addCarDetailsController = self.childViewControllers[1] as! AddCarDetailsViewController
                                            addCarDetailsController.getSellingPoints()
                                        }
                                    } else {
                                        self.chooseView(self.nextStep)
                                    }
                                }
                            } else {
                                self.packageContainer.hidden = false
                                if (Int(error["code"]!)==401){
                                    self.showSignInAlertAction(nil)
                                } else {
                                    self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if self.nextStep == 3 {
                let childController = self.childViewControllers[1] as! AddCarDetailsViewController
                parameters = carDetails
                parameters["_method"] = "put"
                parameters["mileage"] = childController.mileageTextField.text!
                parameters["phone1"] = childController.phone1TextField.text!
                parameters["phone2"] = childController.phone2TextField.text!
                parameters["price"] = childController.carPriceTextField.text!
            } else {
                parameters["_method"] = "put"
            }
            if self.nextStep == 4 {
                self.uploadImages.hidden = true
            }
            if sender.tag == 1 {
                parameters["last"] = "1"
            }
            parameters["steps"] = String(self.nextStep)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("sellcar/\(newCarAdvertID)").request(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination, messageError) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.progressActivityIndicator.hidden = true
                        self.saveAndContinue.hidden = false
                        if self.selectedAdvertId > 0 {
                            self.saveButton.hidden = false
                        }
                        if let error = messageError {
                            if (Int(error["code"]!)==200) {
                                self.nextStep = resultset!["par"]!["steps"].int!
                                self.lastStep = self.nextStep
                                self.uploadImages.hidden = true
                                self.uploadProgress.hidden = true
                                if self.nextStep==4 {
                                    self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
                                    self.uploadProgress.hidden = false
                                    self.progressBar.setProgress(0.5, animated: true)
                                    self.saveAndContinue.hidden = true
                                    self.saveButton.hidden = true
                                } else if self.nextStep==5 {
                                    gloabalAssets = [DKAsset]()
                                    self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
                                    self.progressBar.setProgress(0.75, animated: true)
                                    let previewController = self.childViewControllers[3] as! PreviewViewController
                                    previewController.getOnlineAdvert(self.nextStep)
//                                    self.saveAndContinue.hidden = true
//                                    self.saveButton.hidden = true
                                } else if self.nextStep==6 {
                                    self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0xed563e)
                                    self.progressBar.setProgress(1.0, animated: true)
                                    let confirmController = self.childViewControllers[4] as! ConfirmViewController
                                    confirmController.getOnlineAdvert(self.nextStep)
                                    self.saveAndContinue.setTitle(self.utility.__("completeTheCheckout"), forState: UIControlState.Normal)
                                } else if self.nextStep==7 {
                                    self.firstBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.secondBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.thirdBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.fourthBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.fifthBullet.backgroundColor = self.utility.colorFromRGB(0x4caf50)
                                    self.progressBar.setProgress(1.0, animated: true)
                                    let thanksController = self.childViewControllers[5] as! ThanksViewController
                                    thanksController.viewThanksMessage()
                                    self.stepsBar.hidden = true
                                    self.uploadProgress.hidden = true
                                    self.toolbarView.hidden = true
                                }
                            } else {
                                if (Int(error["code"]!)==401){
                                    self.showSignInAlertAction(nil)
                                } else {
                                    self.utility.showAlert(self, alertTitle: error["title"]!, alertMessage: error["message"]!)
                                }
                            }
                        }
                        self.packageContainer.hidden = true
                        self.vehicleDetailsContainer.hidden = self.nextStep==3 ? false : true
                        self.cameraRollContainer.hidden = self.nextStep==4 ? false : true
                        self.previewContainer.hidden = self.nextStep==5 ? false : true
                        self.confirmContainer.hidden = self.nextStep==6 ? false : true
                        self.thanksContainer.hidden = self.nextStep==7 ? false : true
                        
                        self.firstLabel.hidden = true
                        self.secondLabel.hidden = self.nextStep==3 ? false : true
                        self.thirdLabel.hidden = self.nextStep==4 ? false : true
                        self.fourthLabel.hidden = self.nextStep==5 ? false : true
                        self.fifthLabel.hidden = self.nextStep==6 ? false : true
                    }
                }
            }
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
        progressActivityIndicator.hidden = false
        if username.text != nil && password.text != nil {
            let parameters = ["user_id": username.text!, "password": password.text!]
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.worker.makeUrl("login").requestAndSave(Worker.Method.POST, parameters: parameters) {
                    (resultset, pagination) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let user = resultset?.dictionaryValue["users"] {
                            for (key, value) in user {
                                profile[key] = value.stringValue
                            }
                        }
                        if resultset?.count <= 0 {
                            self.saveAndContinue.hidden = true
                            self.showSignInAlertAction(nil)
                        } else {
                            if let accessToken = resultset!["accessToken"].string {
                                preference!.setValue(accessToken, forKey: "accessToken")
                                preference!.synchronize()
                            }
                            self.saveAndContinue.hidden = false
                        }
                        self.progressActivityIndicator.hidden = true
                    }
                }
            }
        } else {
            self.utility.showAlert(self, alertTitle: utility.__("warning"), alertMessage: utility.__("emptyFields"))
            self.showSignInAlertAction(nil)
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
                        //                self.showSignInAlertAction(nil)
                        self.utility.showAlert(self, alertTitle: self.utility.__("success"), alertMessage: self.utility.__("registrationMessage"))
                    }
                }
            }
        }
    }
    
}
