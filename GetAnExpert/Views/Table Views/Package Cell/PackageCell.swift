//
//  PackageCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 09/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class PackageCell: UITableViewCell {
    
    /* MARK:- Outlets */
    @IBOutlet weak var packageDescription   : UILabel!
    @IBOutlet weak var packageLabel         : UILabel!
    @IBOutlet weak var packagePrice         : UILabel!
    @IBOutlet weak var packageImage         : UIImageView!
    @IBOutlet weak var bookNowButton        : UIButton!
    @IBOutlet weak var editButton           : UIButton!
    @IBOutlet weak var deleteButton         : UIButton!
    @IBOutlet weak var menuButton           : UIButton!
    @IBOutlet weak var menuView             : UIView!
    
    /* MARK:- Properties */
    var package: PackagesModel? {
        didSet {
            configure()
        }
    }
    
    var index: Int = 0
    
    /* MARK:- Closures */
    var didTapBookNow: ((_ index: Int)->())?
    
    /* MARK:- Lifecycle */
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    
    override func prepareForReuse() { 
        bookNowButton.alpha = 0.0
        menuButton.alpha    = 0.0
        menuView.alpha      = 0.0
    }
    
}

/* MARK:- Methods */
extension PackageCell {
    func setLayout() {
        selectionStyle = .none
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.packageImage .layer.cornerRadius = self.packageImage .bounds.height / 8
            self.bookNowButton.layer.cornerRadius = self.bookNowButton.bounds.height / 8
        }
        
        bookNowButton.alpha = 0.0
        menuButton.alpha    = 0.0
        menuView.alpha      = 0.0
    }
    
    func configure(){
        if let package = package {
            packageLabel.text       = package.name
            packagePrice.text       = "$\(package.price)"
            packageDescription.text = package.description
            
            let placeholder = UIImage(named: "placeholder")
            let strURL = package.image.replacingOccurrences(of: " ", with: "%20")
            if let url = URL(string: strURL) {
                packageImage.kf.setImage(with: url, placeholder: placeholder)
            }
        }
    }
}

/* MARK:- Actions */
extension PackageCell {
    @IBAction func didTapBookNow(_ sender: UIButton) {
        didTapBookNow?(index)
    }
}
