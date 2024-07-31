//
//  ServiceCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Cosmos
import SwiftyJSON

class ServiceCell: UICollectionViewCell {
    /* MARK:- Outlets */
    @IBOutlet weak var mainView         : UIView!
    @IBOutlet weak var priceView        : UIView!
    @IBOutlet weak var ratingView       : CosmosView!
    @IBOutlet weak var profileImageView : UIView!

    @IBOutlet weak var nameLabel        : UILabel!
    @IBOutlet weak var priceLabel       : UILabel!
    @IBOutlet weak var ratingLabel      : UILabel!
    @IBOutlet weak var userNameLabel    : UILabel!
        
    @IBOutlet weak var profileImage     : UIImageView!
    @IBOutlet weak var serviceImage     : UIImageView!
    @IBOutlet weak var favUnfavImage    : UIImageView!
    
    @IBOutlet weak var favUnfavButton   : UIButton!
    
    /* MARK:- Computed Properties */
    var service: FeaturedServices? {
        didSet {
            cofigure()
        }
    }
    
    /* MARK:- Properties */
    var index      : Int = 0
    var refrenceVC : FavoritesVC?
    
    /* MARK:- Closures */
    var didTapCellButton : (()->())?
    
    /* MARK:- Lifecycle */
    override func awakeFromNib() {
        super.awakeFromNib()
        setlayout()
    }
    
    override func prepareForReuse() {
        nameLabel.text     = ""
        priceLabel.text    = ""
        userNameLabel.text = ""
        profileImage.image = UIImage(named: "placeholder")
        serviceImage.image = UIImage(named: "placeholder")
    }
}

/* MARK:- Methods */
extension ServiceCell {
    func setlayout() {
        DispatchQueue.main.async {
            self.mainView.layer.cornerRadius         = 5
            self.priceView.layer.cornerRadius        = self.priceView.bounds.height / 8
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
        }
    }
    
    func cofigure(){
        if let service = service {
            nameLabel.text     = service.name
            priceLabel.text    = "$\(service.price)"
            userNameLabel.text = service.user.name
            
            let placeholder    = UIImage(named: "placeholder")

            let strProfileImageUrl = service.user.image.replacingOccurrences(of: " ", with: "%20")
            let strServiceImageUrl = service.image
            
            if let profileImageUrl = URL(string: strProfileImageUrl) {
                profileImage.kf.setImage(with: profileImageUrl, placeholder: placeholder)
            }
            
            if let serviceImageUrl = URL(string: strServiceImageUrl.replacingOccurrences(of: "", with: "%20")) {
                serviceImage.kf.setImage(with: serviceImageUrl, placeholder: placeholder)
            }
            
            if service.rating != 0.0 {
                ratingLabel.text  = "\(Helper.precise(doubleValue: service.rating, ByUnits: 10))"
                ratingView.rating = service.rating
            } else {
                ratingLabel.text = "N/A"
                ratingView.rating = 0.0
            }
            
            if service.isFavourite {
                favUnfavButton.isSelected = true
                self.favUnfavImage.image  = UIImage(named: "fav")
            } else {
                favUnfavButton.isSelected = false
                self.favUnfavImage.image  = UIImage(named: "unfav")
            }
        }
    }
}

/* MARK:- Actions */
extension ServiceCell {
    @IBAction func didTapCell(_ sender: UIButton) {
        didTapCellButton?()
    }
    
    @IBAction func toggleFavUnfav(_ sender: UIButton) {
        if let service = self.service {
            sender.isSelected = !sender.isSelected
            
            if sender.isSelected {
                fvouriteService(service.id)
            } else {
                unFavouriteService(service.id)
            }
        }
    }
}

/* MARK:- API Methods */
extension ServiceCell {
    func fvouriteService(_ serviceId: String) {
        NetworkManager.sharedInstance.favoutirePackage(serviceId: serviceId) { [weak self] (response) in
            guard let self = self else { return }
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let _ = try JSON(data: response.data!)
                            self.favUnfavImage.image = UIImage(named: "fav")
                            
                            if let refrenceVC = self.refrenceVC {
                                refrenceVC.didNeedsRefresh?()
                            }
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
        }
    }
    
    func unFavouriteService(_ serviceId: String) {
        NetworkManager.sharedInstance.unfavoutirePackage(serviceId: serviceId) { [weak self] (response) in
            guard let self = self else { return }
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let _ = try JSON(data: response.data!)
                            self.favUnfavImage.image = UIImage(named: "unfav")
                            
                            if let refrenceVC = self.refrenceVC {
                                refrenceVC.didNeedsRefresh?()
                            }
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
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
