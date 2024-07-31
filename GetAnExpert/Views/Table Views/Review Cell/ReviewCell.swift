//
//  ReviewCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 09/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {
    
    /* MARK:- Outlets */
    @IBOutlet weak var ratingView           : CosmosView!
    @IBOutlet weak var userName             : UILabel!
    @IBOutlet weak var userImage            : UIImageView!
    @IBOutlet weak var reviewText           : UITextView!
    
    var rating: RatingModel? {
        didSet {
            config()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    
    func setLayout() {
        selectionStyle = .none
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.userImage .layer.cornerRadius = self.userImage .bounds.height / 8
        }
    }
    
}

extension ReviewCell {
    func config() {
        if let rating = self.rating {
            userName.text     = rating.user.name
            reviewText.text   = rating.content
            ratingView.rating = rating.stars
            
            if let url = URL(string: rating.user.profile.image) {
                userImage.kf.setImage(with: url)
            }
        }
    }
}
