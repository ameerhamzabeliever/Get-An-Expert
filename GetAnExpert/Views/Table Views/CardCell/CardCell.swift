//
//  CardCell.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    
    /* MARK:- Outlets */
    @IBOutlet weak var cardNumber   : UILabel!
    @IBOutlet weak var mainView     : UIView!
    @IBOutlet weak var selectButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib() 
        setLayout()
    }
    
    func setLayout() {
        selectionStyle = .none
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.mainView .layer.cornerRadius = self.mainView .bounds.height / 10
        }
    }
    
}
