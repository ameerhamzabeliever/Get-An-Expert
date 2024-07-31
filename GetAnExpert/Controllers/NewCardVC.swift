//
//  NewCardVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class NewCardVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var cardNumberView   : UIView!
    @IBOutlet weak var cardNameView     : UIView!
    @IBOutlet weak var cardExpiryView   : UIView!
    @IBOutlet weak var cardCVCView      : UIView!
    @IBOutlet weak var saveButtonView   : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}

/* MARK:- Methods */
extension NewCardVC {
    
    func setupVC() {
        setLayout()
    }
    func setLayout(){
        DispatchQueue.main.async {
            self.cardNumberView.layer.cornerRadius = self.cardNumberView.bounds.height / 8
            self.cardNameView  .layer.cornerRadius = self.cardNameView  .bounds.height / 8
            self.cardExpiryView.layer.cornerRadius = self.cardExpiryView.bounds.height / 8
            self.cardCVCView   .layer.cornerRadius = self.cardCVCView   .bounds.height / 8
            self.saveButtonView.layer.cornerRadius = self.saveButtonView.bounds.height / 8
        }
    }
}


/* MARK:- Actions */
extension NewCardVC {
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
