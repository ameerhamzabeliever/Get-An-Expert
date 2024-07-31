//
//  UserProfileVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 03/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Braintree
import SwiftyJSON
import BraintreeDropIn

class UserProfileVC: UIViewController, BTViewControllerPresentingDelegate, BTAppSwitchDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
            
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
    
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
    
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
    
    /* MARK:- Outlets */
    @IBOutlet weak var profileImageView : UIView!
    @IBOutlet weak var guestView        : UIView!
    @IBOutlet weak var loginButton      : UIButton!
    @IBOutlet weak var profileNumber    : UILabel!
    @IBOutlet weak var profileName      : UILabel!
    @IBOutlet weak var profileImage     : UIImageView!
    @IBOutlet weak var userImage        : UIImageView!
    
    /* MARK:- Properties */
    /// PAYPAL
    var braintreeClient: BTAPIClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        getProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setGuestView()
        loadData()
    }
    
}

/* MARK:- Methods */
extension UserProfileVC {
    
    func setupVC() {
        setlayout()
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
            self.userImage.layer.cornerRadius = self.userImage.bounds.height / 2
            self.loginButton.layer.cornerRadius =   self.loginButton.bounds.height / 8
        }
    }
    func setGuestView() {
        if Constants.sharedInstance.isGuestUser {
            guestView.alpha = 1.0
        } else {
            guestView.alpha = 0.0
            loadData()
        }
    }
    func loadData(){
        if let user = Constants.sharedInstance.USER {
            profileName.text   = user.name
            profileNumber.text = "\(user.code)-\(user.phone)"
            Helper.setImage(isUser: true, imageView: profileImage, imageUrl: user.image)
            Helper.setImage(isUser: true, imageView: userImage, imageUrl: user.image)
        }
    }
    
    /// PAYPAL
    func startCheckout() {
        braintreeClient  = BTAPIClient(authorization: PAYPAL_TOKENIZATION)
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate                = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let request          = BTPayPalRequest(amount: "2.32")
        request.currencyCode = "USD"
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                
                // Access additional information
                let email     = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName  = tokenizedPayPalAccount.lastName
                let phone     = tokenizedPayPalAccount.phone
                
                // See BTPostalAddress.h for details
                let billingAddress  = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
            } else if let error = error {
                // Handle error here...
            } else {
                // Buyer canceled payment approval
            }
        }
    }
    
}

/* MARK:- Actions */
extension UserProfileVC {
    
    @IBAction func profileSettingsAction(_ sender: UIButton){
        let userVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.USER_INFO_VC)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    @IBAction func qaHistoryAction(_ sender: UIButton){}
    
    @IBAction func addressAction(_ sender: UIButton){
        let addressVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.ADDRESS_VC)
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    @IBAction func helpCenterAction(_ sender: UIButton){}
    
    @IBAction func paymentMethodAction(_ sender: UIButton){
        let paymentVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.ADD_PAYMENT_VC)
        self.navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    @IBAction func aboutUsAction(_ sender: UIButton){
        self.startCheckout()
//        let twilioChatVC = TwilioChatVC(nibName: Constants.ViewControllers.CHAT_VC, bundle: nil)
//        navigationController?.pushViewController(twilioChatVC, animated: true)
    }
    
    @IBAction func logoutAction(_ sender: UIButton){
        let viewControllers = self.navigationController!.viewControllers
        for viewController in viewControllers {
            if viewController is LoginVC  {
                Constants.sharedInstance.USER = nil
                self.navigationController?.popToViewController(
                    viewController,
                    animated: true
                )
            }
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton){
        var vcFound = false
        let viewControllers = self.navigationController!.viewControllers
        for vc in viewControllers {
            if vc is LoginVC {
                vcFound = true
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
        if !vcFound {
            let loginVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.LOGIN_VC)
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}

/* MARK:- Api Methods */
extension UserProfileVC {
    func getProfile(){
        self.showSpinner(onView: self.view, title: "Getting Profile")
        NetworkManager.sharedInstance.getProfile {
            (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200 {
                        let user  = UserModel(json: data["data"])
                        Constants.sharedInstance.USER = user
                        
                    } else {
                        self.showAlert(message: data["data"]["errors"]["message"].stringValue)
                    }
                } catch {
                    self.showAlert(message: error.localizedDescription)
                }
            case .failure(_):
                self.showAlert(message: "Something went wrong with Servers")
            }
        }
    }
}
