//
//  ProviderProfileVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 04/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProviderProfileVC: UIViewController {
    /* MARK:- Outlets */
    @IBOutlet weak var profileImageView : UIView!
    @IBOutlet weak var ticketView       : UIView!
    @IBOutlet weak var profileNumber    : UILabel!
    @IBOutlet weak var profileName      : UILabel!
    @IBOutlet weak var profileImage     : UIImageView!
    @IBOutlet weak var userImage        : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        getProfile()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
}

/* MARK:- Methods */
extension ProviderProfileVC {
    
    func setupVC() {
        setlayout()
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
            self.userImage.layer.cornerRadius = self.userImage.bounds.height / 2
            self.ticketView.layer.cornerRadius       = self.ticketView.bounds.height / 6
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
}

/* MARK:- Actions */
extension ProviderProfileVC {
    
    @IBAction func ticketAction(_ sender: UIButton){
        tabBarController?.selectedIndex = 1
    }
    @IBAction func profileSettingsAction(_ sender: UIButton){
        let userVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_INFO_VC)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    @IBAction func appointmentsAction(_ sender: UIButton){
        tabBarController?.selectedIndex = 1
    }
    @IBAction func addressAction(_ sender: UIButton){
        let addressVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.ADDRESS_VC
        )
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    @IBAction func paymentMethodAction(_ sender: UIButton){
        let paymentVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.ADD_PAYMENT_VC
        )
        self.navigationController?.pushViewController(paymentVC, animated: true)
    }
    @IBAction func packagesAction(_ sender: UIButton) {
        let packagesVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.PACKAGES_VC
        )
        self.navigationController?.pushViewController(packagesVC, animated: true)
    }
    @IBAction func slotsMangmentAction(_ sender: UIButton){
        let createSlotsVC = CreateSlotsVC(
            nibName: Constants.ViewControllers.CREATE_SLOTS_VC,
            bundle: nil
        )
        
        self.navigationController?.pushViewController(createSlotsVC, animated: true)
    }
    
    @IBAction func aboutUsAction(_ sender: UIButton){}
    
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
}

extension ProviderProfileVC{
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

