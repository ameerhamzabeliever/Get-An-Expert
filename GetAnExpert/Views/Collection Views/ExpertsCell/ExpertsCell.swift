//
//  ExpertsCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Kingfisher

class ExpertsCell: UICollectionViewCell {
    /* MARK:- Outlets */
    @IBOutlet weak var mainView         : UIView!
    @IBOutlet weak var ratingView       : UIView!
    @IBOutlet weak var profileImageView : UIImageView!
    
    @IBOutlet weak var nameLabel        : UILabel!
    @IBOutlet weak var ratingLabel      : UILabel!
    @IBOutlet weak var addressLabel     : UILabel!
    @IBOutlet weak var categoryLabel    : UILabel!
    
    
    /* MARK:- Properties */
    var categoryUser: UserModel? {
        didSet {
            configue()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setlayout()
    }
    
    override func prepareForReuse() {
        nameLabel.text         = ""
        ratingLabel.text       = ""
        categoryLabel.text     = ""
        addressLabel.text      = ""
        profileImageView.image = UIImage(named: "placeholder")
    }
}

/* MARK:- Methods */
extension ExpertsCell {
    func setlayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.mainView.layer.cornerRadius         = self.mainView.bounds.height   / 14
            self.ratingView.layer.cornerRadius       = self.ratingView.bounds.height / 2
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 8
        }
    }
    
    func configue(){
        if let categoryUser = self.categoryUser {
            nameLabel.text     = categoryUser.name
            categoryLabel.text = categoryUser.category.name
            
            if categoryUser.address.country != "" {
                addressLabel.text  = "\(categoryUser.address.city),\(categoryUser.address.country)"
            } else {
                addressLabel.text  = "\(categoryUser.address.city)"
            }
            
            if categoryUser.rating != 0.0 {
                self.ratingLabel.text = "\(Helper.precise(doubleValue: categoryUser.rating, ByUnits: 10))"
            } else {
                self.ratingLabel.text = "N/A"
            }
            
            let strUrl = categoryUser.image.replacingOccurrences(of: " ", with: "%20")
            if let url = URL(string: strUrl) {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            }
        }
    }
}
