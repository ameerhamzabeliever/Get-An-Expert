//
//  RejectedCell.swift
//  GetAnExpert
//
//  Created by Office on 05/12/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class RejectedCell: UITableViewCell {

    /* MARK:- Outlets */
    @IBOutlet weak var mainView             : UIView!
    @IBOutlet weak var appointmentImageView : UIView!
    @IBOutlet weak var appointmentImage     : UIImageView!
    @IBOutlet weak var title                : UILabel!
    @IBOutlet weak var clientName           : UILabel!
    @IBOutlet weak var statusLabel          : UILabel!
    @IBOutlet weak var buttonsView          : UIStackView!
    @IBOutlet weak var acceptButton         : UIButton!
    @IBOutlet weak var rejectButton         : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setLayout() {
        selectionStyle = .none
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            self.appointmentImageView.layer.cornerRadius = self.appointmentImageView.bounds.height / 8
            self.mainView.layer.cornerRadius     = self.mainView.bounds.height / 8
            self.acceptButton.layer.cornerRadius = self.acceptButton.bounds.height / 8
            self.rejectButton.layer.cornerRadius = self.rejectButton.bounds.height / 8
        }
    }
}
