//
//  CategoryCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell {
    
    /* MARK:- Outlets */
    @IBOutlet weak var mainView          : UIView!
    @IBOutlet weak var categoryImageView : UIImageView!
    @IBOutlet weak var categoryNameLabel : UILabel!
    
    /* MARK:- Properties */
    var category: CategoriesModel? {
        didSet {
            configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setlayout()
    }
}

/* MARK:- Methods */
extension CategoryCell {
    func setlayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainView.layer.cornerRadius = self.mainView.bounds.height / 14
            self.categoryImageView.layer.cornerRadius = self.categoryImageView.bounds.height / 8
        }
    }
    
    func configureCell(){
        if let category = self.category {
            categoryNameLabel.text = category.name
            let strURL = category.image.replacingOccurrences(of: " ", with: "%20")
            if let url = URL(string: strURL) {
                categoryImageView.kf.setImage(with: url, placeholder: PLACEHOLDER_IMAGE)
            } 
        }
    }
}
