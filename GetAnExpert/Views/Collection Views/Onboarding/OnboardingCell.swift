//
//  OnboardingCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 25/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class OnboardingCell: UICollectionViewCell {

    /* MARK:- IBOutlets */
    @IBOutlet weak var onboadringImage       : UIImageView!
    @IBOutlet weak var onboadringTitle       : UILabel!
    @IBOutlet weak var onboadringDescription : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
extension OnboardingCell {
    
    func setCell(Title: String, Description: String, Image: String) {
        self.onboadringTitle.text       = Title
        self.onboadringDescription.text = Description
        self.onboadringImage.image      = UIImage(named: Image)
    }
}
