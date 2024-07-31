//
//  ForgetVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ForgetVC: UIViewController {

    /* MARK:- Outlets */
    @IBOutlet weak var btnResetView : UIView!
    @IBOutlet weak var emailTF      : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }

}
/* MARK:- Methods */
extension ForgetVC {
    
    func setupVC() {
        setlayout()
    }
    func setlayout() {
        DispatchQueue.main.async {
            self.btnResetView.layer.cornerRadius   = self.btnResetView.bounds.height / 8
        }
    }
}

/* MARK:- Actions */
extension ForgetVC {
    
    @IBAction func resetAction(_ sender: UIButton){
        resetPassword()
    }
    
    @IBAction func BackAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

/* MARK:- Api Methods */
extension ForgetVC {
    
    func resetPassword(){
        var parameters : [String : Any] = [:]
        guard let email = emailTF.text,  email != "" else {
            self.showToast(message: "Email Field is Required")
            return
        }
        let lowerCaseEmail  = email.lowercased()
        parameters["email"] = lowerCaseEmail
        self.showSpinner(onView: self.view)
        NetworkManager.sharedInstance.resetPassword(param: parameters) {
            (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 200 {
                    self.showAlertWithAction(message: "Reset Password link is send to given email") { (isCompleted) in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showToast(message: "User doesn't exist in record")
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
}
