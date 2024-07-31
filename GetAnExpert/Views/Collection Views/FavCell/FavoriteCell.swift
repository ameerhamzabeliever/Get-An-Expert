//
//  FavoriteCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class FavoriteCell: UICollectionViewCell {
    
    /* MARK:- Outlets */
    @IBOutlet weak var ratingView         : UIView!
    @IBOutlet weak var ratingLable        : UILabel!
    @IBOutlet weak var providerName       : UILabel!
    @IBOutlet weak var providerSpeciality : UILabel!
    @IBOutlet weak var profileImageView   : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setlayout()
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.contentView.layer.cornerRadius      = self.contentView.bounds.height / 10
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 10
            self.ratingView.roundCorners(corners: .bottomLeft, radius: self.ratingView.bounds.height / 2)
        }
    }
}
