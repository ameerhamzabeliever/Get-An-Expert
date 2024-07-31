//
//  LoginVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 25/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleSignIn
import FacebookCore
import FBSDKLoginKit
import FacebookLogin
import LinkedinSwift

class LoginVC: UIViewController, GIDSignInDelegate {
    
    /* MARK:- Outlets */
    @IBOutlet weak var btnSignUpView    : UIView!
    @IBOutlet weak var btnFBView        : UIView!
    @IBOutlet weak var btnGoogleView    : UIView!
    @IBOutlet weak var btnLinkedInView  : UIView!
    @IBOutlet weak var btnGuestView     : UIView!
    
    @IBOutlet weak var btnConsumer         : UIButton!
    @IBOutlet weak var btnServiceProvider  : UIButton!
    
    @IBOutlet weak var emailTF          : UITextField!
    @IBOutlet weak var passwordTF       : UITextField!
    
    /* MARK:- Properties */
    var registrationToken = Constants.sharedInstance.fcmToken
    var isRemember : Bool = false
    var userType   : Int = 0 // 0 = Consumer, 1 = Service Provider
    let linkedinHelper   = LinkedinSwiftHelper (
        configuration    : LinkedinSwiftConfiguration (
            clientId         : "77cz3vxyws8q4w",
            clientSecret     : "4uYxPqvsedIHMCjk",
            state            : "linkedin\(Int(NSDate().timeIntervalSince1970))",
            permissions      : ["r_liteprofile", "r_emailaddress"],
            redirectUrl      : "https://com.codesbinary.linkedin.oauth/oauth"),
        nativeAppChecker : WebLoginOnly()
    )
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupVC()
        setTextFields()
    }
    
}

/* MARK:- Methods */
extension LoginVC {
    
    func setupVC() {
        setlayout()
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.btnSignUpView.layer.cornerRadius   = self.btnSignUpView.bounds.height   / 8
            self.btnFBView.layer.cornerRadius       = self.btnFBView.bounds.height       / 8
            self.btnGoogleView.layer.cornerRadius   = self.btnGoogleView.bounds.height   / 8
            self.btnLinkedInView.layer.cornerRadius = self.btnLinkedInView.bounds.height / 8
            self.btnGuestView.layer.cornerRadius    = self.btnGuestView.bounds.height / 8
            self.btnConsumer.roundCorners(corners: [.topLeft,.bottomLeft], radius: self.btnConsumer.bounds.height / 8)
            self.btnServiceProvider.roundCorners(corners: [.topRight,.bottomRight], radius: self.btnServiceProvider.bounds.height / 8)
        }
    }
    func resetTextFields(){
        emailTF    .text = ""
        passwordTF .text = ""
    }
    func setTextFields() {
        emailTF   .text = Constants.sharedInstance.Email
        passwordTF.text = Constants.sharedInstance.Password
    }
    
    func facebookClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email, .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.showToast(message: "\(error)")
            case .cancelled:
                print("User cancelled login.")
            case .success( _, _, let token):
                self.facebookLogin(access_token: token.tokenString)
            }
        }
    }
    
    func googleClicked() {
        GIDSignIn.sharedInstance().clientID = "105111735905-j9b8og3tgbul4p98afbp2gomqhj7khon.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func linkedInClicked(){
        linkedinHelper.authorizeSuccess({ [unowned self] (lsToken) -> Void in
            self.showAlert(message: "\(lsToken)")
            }, error: { [unowned self] (error) -> Void in
                self.showAlert(message: "Encounter error: \(error.localizedDescription)")
            }, cancel: { [unowned self] () -> Void in
                self.showAlert(message: "User Cancelled!")
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.showToast(message: "\(error.localizedDescription)")
        } else {
            let idToken = user.authentication.accessToken ?? ""
            if idToken != "" {
                self.googleLogin(access_token: idToken)
            }
        }
    }
}
/* MARK:- Actions */
extension LoginVC {
    
    @IBAction func LoginAction(_ sender: UIButton){
        if !isRemember {
            Constants.sharedInstance.Email    = ""
            Constants.sharedInstance.Password = ""
        }
        loginUser()
    }
    @IBAction func SignUpAction(_ sender: UIButton){
        let registerVC =  MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.REGISTER_VC) as! RegisterVC
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func facebookAction(_ sender: UIButton){
        facebookClicked()
    }
    
    @IBAction func googleAction(_ sender: UIButton){
        googleClicked()
    }
    
    @IBAction func linkedInAction(_ sender: UIButton){
        linkedInClicked()
    }
    
    @IBAction func userTypeAction(_ sender: UIButton){
        btnConsumer.backgroundColor        = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        btnServiceProvider.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        sender.backgroundColor             = #colorLiteral(red: 0.9369999766, green: 0.4429999888, blue: 0.4199999869, alpha: 1)
        if sender.accessibilityIdentifier == "consumer" {
            userType = 0
        } else {
            userType = 1
        }
    }
    
    @IBAction func forgetAction(_ sender: UIButton){
        let forgetVC =  MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.FORGET_VC) as! ForgetVC
        self.navigationController?.pushViewController(forgetVC, animated: true)
    }
    @IBAction func guestAction(_ sender: UIButton){
        let homeVC =  MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
        Constants.sharedInstance.isGuestUser = true
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    @IBAction func rememberMe(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            isRemember = true
        } else {
            isRemember = false
        }
    }
}

/* MARK:- Api Methods */
extension LoginVC {
    
    func loginUser() {
        var parameters : [String : Any] = [:]
        guard let email = emailTF.text, email != "" else {
            self.showAlert(message: "Enter Your Email Address")
            return
        }
        guard let password = passwordTF.text, password != "" else {
            self.showAlert(message: "Please Provide Password first")
            return
        }
        if password.count < 6 {
            self.showAlert(message: "Password must contains Min 6 Character")
            return
        }
        let lowerCaseEmail     = email.lowercased()
        parameters["email"]    = lowerCaseEmail
        parameters["password"] = password
        parameters["registrationToken"] = registrationToken
        self.showSpinner(onView: self.view)
        NetworkManager.sharedInstance.login(param: parameters) {
            (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200 {
                        self.resetTextFields()
                        Constants.sharedInstance.isGuestUser = false
                        let token = "Bearer \(data["data"]["token"].stringValue)"
                        let registrationToken = data["data"]["registrationToken"].stringValue
                        
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        DEFAULTS.synchronize()
                        
                        let user  = UserModel(json: data["data"]["user"])
                        Constants.sharedInstance.USER = user
                        
                        if self.isRemember {
                            Constants.sharedInstance.Email    = email
                            Constants.sharedInstance.Password = password
                        }
                        
                        if user.isVerfifed != "" {
                            if user.isProvider {
                                let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_HOME_VC)
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            } else {
                                let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }
                        } else {
                            
                            let verificationVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.VALIDATION_VC)
                            self.navigationController?.pushViewController(verificationVC, animated: true)
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
    
    func googleLogin(access_token: String){
        var parameters : [String : Any] = [:]
        parameters["access_token"] = access_token
        
        if userType == 1 {
            parameters["serviceProvider"] = userType
        }
        
        self.showSpinner(onView: self.view, title: "Logging In....")
        NetworkManager.sharedInstance.googleLogin(param: parameters, completion: { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200 {
                        self.resetTextFields()
                        Constants.sharedInstance.isGuestUser = false
                        let token = "Bearer \(data["data"]["token"].stringValue)"
                        
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        DEFAULTS.synchronize()
                        
                        let user  = UserModel(json: data["data"]["user"])
                        Constants.sharedInstance.USER = user
                        
                        if user.isProvider {
                            let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_HOME_VC)
                            self.navigationController?.pushViewController(homeVC, animated: true)
                        } else {
                            let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
                            self.navigationController?.pushViewController(homeVC, animated: true)
                        }
                    } else {
                        self.showToast(message: data["message"].stringValue)
                    }
                } catch {
                    self.showToast(message: error.localizedDescription)
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        })
    }
    
    func facebookLogin(access_token: String){
        var parameters : [String : Any] = [:]
        parameters["access_token"]    = access_token
        if userType == 1 {
            parameters["serviceProvider"] = userType
        }
        self.showSpinner(onView: self.view, title: "Logging In....")
        NetworkManager.sharedInstance.facebookLogin(param: parameters, completion: { (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200 {
                        self.resetTextFields()
                        Constants.sharedInstance.isGuestUser = false
                        let token = "Bearer \(data["data"]["token"].stringValue)"
                        
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        DEFAULTS.synchronize()
                        
                        let user  = UserModel(json: data["data"]["user"])
                        Constants.sharedInstance.USER = user
                        
                        if user.isProvider {
                            let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_HOME_VC)
                            self.navigationController?.pushViewController(homeVC, animated: true)
                        } else {
                            let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
                            self.navigationController?.pushViewController(homeVC, animated: true)
                        }
                    } else {
                        self.showToast(message: data["message"].stringValue)
                    }
                } catch {
                    self.showToast(message: error.localizedDescription)
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        })
    }
}
