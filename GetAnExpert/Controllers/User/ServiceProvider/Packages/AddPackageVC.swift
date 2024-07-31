//
//  AddPackageVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 11/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import YPImagePicker

class AddPackageVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var packageImage     : UIImageView!
    @IBOutlet weak var selectBtnView    : UIView!
    @IBOutlet weak var nameView         : UIView!
    @IBOutlet weak var priceView        : UIView!
    @IBOutlet weak var descriptionView  : UIView!
    
    @IBOutlet weak var nameTextfield        : UITextField!
    @IBOutlet weak var priceTextfield       : UITextField!
    @IBOutlet weak var descriptionTextView  : UITextView!
    
    @IBOutlet weak var saveLable  : UILabel!
    @IBOutlet weak var saveButton : UIButton!
    
    /* MARK:- Properties */
    var isUpdate : Bool = false
    
    var package    : PackagesModel?
    var refrenceVC : PackagesVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}

/* MARK:- Methods */
extension AddPackageVC {
    
    func setupVC() {
        priceTextfield.keyboardType = UIKeyboardType.numberPad
        setlayout()
        if isUpdate {
            loadData()
        } else {
            packageImage.image = UIImage(named: "placeholder")
        }
    }
    
    func setlayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.packageImage   .layer.cornerRadius = self.packageImage   .bounds.height / 10
            self.selectBtnView  .layer.cornerRadius = self.selectBtnView  .bounds.height / 10
            self.priceView      .layer.cornerRadius = self.priceView      .bounds.height / 10
            self.nameView       .layer.cornerRadius = self.nameView       .bounds.height / 10
            self.descriptionView.layer.cornerRadius = self.descriptionView.bounds.height / 10
            self.saveButton .layer.cornerRadius     = self.saveButton     .bounds.height / 10
        }
    }
    
    func loadData() {
        if let package = package {
            let strUrl = package.image.replacingOccurrences(of: " ", with: "%20")
            if let url = URL(string: strUrl) {
                packageImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            }
            nameTextfield.text       = package.name
            descriptionTextView.text = package.description
            priceTextfield.text      = package.price
        }
        
        saveLable.text = "Update"
    }
    
    func showPickerPhotos() {
        var config                          = YPImagePickerConfiguration()
        config.library.mediaType            = .photo
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen                = .photo
        config.screens                      = [.library]
        config.wordings.libraryTitle        = "Photos"
        config.usesFrontCamera              = true
        config.showsPhotoFilters            = false
        config.hidesStatusBar               = false
        config.hidesBottomBar               = false
        config.library.maxNumberOfItems     = 1
        config.library.onlySquare           = false
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.packageImage.image = photo.image
                     picker.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
}

/* MARK:- Actions */
extension AddPackageVC {
    
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func openGalleryAction(_ sender: UIButton){
        showPickerPhotos()
    }
    @IBAction func saveAction(_ sender: UIButton) {
        if packageImage.image == UIImage(named: "placeholder") {
            self.showAlert(message: "Please select an image for the package")
            return
        }
        
        guard let image = packageImage.image else {
            return
        }
        guard let name = nameTextfield.text, name != "" else {
            self.showAlert(message: "Please enter name for the package")
            return
        }
        guard let price = priceTextfield.text, price != "" else {
            self.showAlert(message: "Please enter price for the package")
            return
        }
        guard let description = descriptionTextView.text, description != "" else {
            self.showAlert(message: "Please enter description for the package")
            return
        }
        
        let parameters : [String: String] = [
            "name"        : name,
            "price"       : price,
            "description" : description
        ]
        
        if isUpdate {
            updatePackage(packageId: package!.id, image: image, imageKey: "image", parameters: parameters)
        } else {
            createPackage(image: image, imageKey: "image", parameters: parameters)
        }
    }
    
}

/* MARK:- API Methods */
extension AddPackageVC {
    func createPackage(image: UIImage, imageKey: String, parameters: [String: String]){
        self.showSpinner(onView: view)
        NetworkManager.sharedInstance.createPackage(
            image       : image,
            imageKey    : imageKey,
            parameters  : parameters
        ) { [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        let alertController = UIAlertController(
                            title           : APP_NAME,
                            message         : "Package created sucessfully",
                            preferredStyle  : .alert
                        )
                        
                        let okay = UIAlertAction(title: "OK", style: .default) { (_) in
                            self.navigationController?.popViewController(animated: true)
                            if let refrenceVC = self.refrenceVC {
                                refrenceVC.didNeedrefresh?()
                            }
                        }
                        
                        alertController.addAction(okay)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }

        }
    }
    
    func updatePackage(packageId: String, image: UIImage, imageKey: String, parameters: [String: String]){
        self.showSpinner(onView: view)
        NetworkManager.sharedInstance.updatePackage(
            packageId   : packageId,
            image       : image,
            imageKey    : imageKey,
            parameters  : parameters
        ) { [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        let alertController = UIAlertController(
                            title           : APP_NAME,
                            message         : "Package created sucessfully",
                            preferredStyle  : .alert
                        )
                        
                        let okay = UIAlertAction(title: "OK", style: .default) { (_) in
                            self.navigationController?.popViewController(animated: true)
                            if let refrenceVC = self.refrenceVC {
                                refrenceVC.didNeedrefresh?()
                            }
                        }
                        
                        alertController.addAction(okay)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }

        }
    }
}
