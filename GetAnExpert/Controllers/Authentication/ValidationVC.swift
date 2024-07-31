//
//  ValidationVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 25/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ValidationVC: UIViewController, UITextFieldDelegate {
    
    /* MARK:- Outlets */
    @IBOutlet weak var btnVerifyView : UIView!
    @IBOutlet weak var codeTF        : UITextField!
    
    var code : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}
/* MARK:- Methods */
extension ValidationVC {
    
    func setupVC() {
        setlayout()
        if let code = code {
            self.showToast(message: code)
        }
        codeTF.delegate = self
        
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.btnVerifyView.layer.cornerRadius   = self.btnVerifyView.bounds.height / 8
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

/* MARK:- Actions */
extension ValidationVC {
    
    @IBAction func verifyAction(_ sender: UIButton){
        verifyCode()
    }
    
    @IBAction func resendAction(_ sender: UIButton){
        resendEmail()
    }
    @IBAction func BackAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}

/* MARK:- Api Methods */
extension ValidationVC {
    
    func resendEmail() {
        self.showSpinner(onView: self.view)
        NetworkManager.sharedInstance.resendEmail{ (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    
                    let token = "Bearer \(data["data"]["token"])"
                    
                    DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                    DEFAULTS.synchronize()
                    
                    if response.response?.statusCode == 200 {
    
                        self.showAlertWithAction(message: "A New Verification Code has been sent to Email") { (isCompleted) in
                            self.showToast(message: "Verification Code: \(data["data"]["verificationCode"])")
                        }
                        
                    } else {
                        self.showToast(message: data["data"]["errors"]["message"].stringValue)
                    }
                } catch {
                    self.showToast(message: error.localizedDescription)
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    
    func verifyCode() {
        var parameters : [String : Any] = [:]
        
        guard let code = codeTF.text, code != "" else {
            self.showAlert(message: "Provide Verification Code Please!")
            return
        }
        if code.count < 4 {
            self.showAlert(message: "Code Must be of 4 digits")
            return
        }
        parameters["verificationCode"] = code
        
        self.showSpinner(onView: self.view)
        NetworkManager.sharedInstance.verifyEmail( param: parameters) { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200 {
                        Constants.sharedInstance.isGuestUser = false
                        let token = "Bearer \(data["data"]["token"].stringValue)"
                        
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        DEFAULTS.synchronize()
                        
                        let user  = UserModel(json: data["data"]["user"])
                        Constants.sharedInstance.USER = user
                        
                        if let user = Constants.sharedInstance.USER {
                            if user.isProvider {
                                let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_HOME_VC)
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            } else {
                                let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }
                        }
                    } else {
                        self.showAlert(message: "Invalid Code")
                    }
                    
                } catch{
                    self.showAlert(message: error.localizedDescription)
                }
            case .failure(_):
                self.showAlert(message: "Something went wrong with Servers")
            }
        }
    }
    
}
