//
//  RightChatCell.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 21/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class RightChatCell: UITableViewCell {

    /* MARK:- IBOutlets */
    @IBOutlet weak var messageLabel     : UILabel!
    @IBOutlet weak var messageLabelView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutView()
    }
}

/* MARK:- Methods */
extension RightChatCell {
    func layoutView(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.messageLabelView.layer.cornerRadius = self.messageLabelView.frame.height / 2
        }
    }
}
