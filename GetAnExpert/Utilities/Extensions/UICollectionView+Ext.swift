//
//  UICollectionView+Ext.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 22/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: self.bounds.size.width,
                                                 height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
    }
    func restore() {
        self.backgroundView = nil
    }
}
