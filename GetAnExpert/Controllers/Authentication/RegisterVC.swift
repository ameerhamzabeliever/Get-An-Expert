//
//  RegisterVC.swift
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
import CountryPickerView
import GooglePlaces

class RegisterVC: UIViewController, GIDSignInDelegate{
    
    
    /* MARK:- Outlets */
    @IBOutlet weak var btnSignUpView       : UIView!
    @IBOutlet weak var btnFBView           : UIView!
    @IBOutlet weak var btnGoogleView       : UIView!
    @IBOutlet weak var btnLinkedInView     : UIView!
    @IBOutlet weak var btnConsumer         : UIButton!
    @IBOutlet weak var btnServiceProvider  : UIButton!
    
    @IBOutlet weak var nameTF              : UITextField!
    @IBOutlet weak var emailTF             : UITextField!
    @IBOutlet weak var numberTF            : UITextField!
    @IBOutlet weak var countryCodeTF       : UITextField!
    @IBOutlet weak var passwordTF          : UITextField!
    @IBOutlet weak var confirmPasswordTF   : UITextField!
    @IBOutlet weak var cityTF              : UITextField!
    
    /* MARK:- Properties */
    var userType   = 0 // 0 = Consumer, 1 = Service Provider
    var country    = ""
    var coutryCode = ""
    var registrationToken = Constants.sharedInstance.fcmToken
    var countryPickerView: CountryPickerView = CountryPickerView()
    let linkedinHelper   = LinkedinSwiftHelper (
        configuration    : LinkedinSwiftConfiguration (
            clientId         : "77cz3vxyws8q4w",
            clientSecret     : "4uYxPqvsedIHMCjk",
            state            : "linkedin\(Int(NSDate().timeIntervalSince1970))",
            permissions      : ["r_liteprofile", "r_emailaddress"],
            redirectUrl      : "https://com.codesbinary.linkedin.oauth/oauth"),
        nativeAppChecker : WebLoginOnly()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}
/* MARK:- Methods */
extension RegisterVC {
    func setupVC() {
        setlayout()
        setValues()
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.btnSignUpView.layer.cornerRadius   = self.btnSignUpView.bounds.height   / 8
            self.btnFBView.layer.cornerRadius       = self.btnFBView.bounds.height       / 8
            self.btnGoogleView.layer.cornerRadius   = self.btnGoogleView.bounds.height   / 8
            self.btnLinkedInView.layer.cornerRadius = self.btnLinkedInView.bounds.height / 8
            self.btnConsumer.roundCorners(corners: [.topLeft,.bottomLeft], radius: self.btnConsumer.bounds.height / 8)
            self.btnServiceProvider.roundCorners(corners: [.topRight,.bottomRight], radius: self.btnServiceProvider.bounds.height / 8)
        }
    }
    func setValues(){
        countryCodeTF.text = "+1"
    }
    
    func facebookClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email, .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
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
            let idToken = user.authentication.idToken ?? ""
            if idToken != "" {
                self.googleLogin(access_token: idToken)
            }
        }
    }
}

/* MARK:- Actions */
extension RegisterVC {
    
    @IBAction func LoginAction(_ sender: UIButton){
        let loginVC =  MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.LOGIN_VC
        ) as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func SignUpAction(_ sender: UIButton){
        signUp()
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
    
    @IBAction func countryCodeAction(_ sender: UIButton){
        countryPickerView.showCountriesList(from: self)
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
    @IBAction func didTapCurrentCity(_ sender: UIButton){
        let acController      = GMSAutocompleteViewController()
        acController.delegate = self
        let filter            = GMSAutocompleteFilter()
        filter.country        = "usa|country:ca"
        
        acController.autocompleteFilter = filter
        
        present(acController, animated: true, completion: nil)
    }
}

/* MARK:- Api Methods */
extension RegisterVC {
    
    func signUp() {
        
        var parameters : [String : Any] = [:]
        guard let name = self.nameTF.text, name != "" else {
            self.showAlert(message: "Please Enter Your Name")
            return
        }
        guard let email = self.emailTF.text, email != "" else {
            self.showAlert(message: "Please Enter Your Valid Email")
            return
        }
        
        guard let code = self.countryCodeTF.text, code != "" else {
            self.showAlert(message: "Select Country Code First")
            return
        }
        guard let number = self.numberTF.text, number != "" else {
            self.showAlert(message: "Provide Your Phone Number")
            return
        }
        guard let password = self.passwordTF.text, password != "" else {
            self.showAlert(message: "Enter Your Password Please!")
            return
        }
        guard let city = self.cityTF.text, city != "" else {
            self.showAlert(message: "Provide Your City Please!")
            return
        }
        
        if password.count < 6 {
            self.showAlert(message: "Password must be Min 6 characters")
            return
        }
        if password != self.confirmPasswordTF.text {
            self.showAlert(message: "Password didn't match")
            return
        }
        
        if !Helper.isValidEmail(email) {
            self.showAlert(message: "Invalid Email Format")
            return
        }
        
        let lowerCaseEmail              = email.lowercased()
        parameters["name"]              = name
        parameters["email"]             = lowerCaseEmail
        parameters["password"]          = password
        parameters["confirmPassword"]   = password
        parameters["phoneNumber"]       = number
        parameters["phoneCode"]         = code
        parameters["city"]              = city
        parameters["country"]           = country
        parameters["countryCode"]       = coutryCode
        parameters["registrationToken"] = registrationToken
        
        if userType == 1 {
            parameters["serviceProvider"] = "true"
        }
        
        self.showSpinner(onView: self.view)
        NetworkManager.sharedInstance.signUp(param: parameters) {
            (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                do {
                    let data = try JSON(data: response.data!)
                    if response.response?.statusCode == 200 {
                        Constants.sharedInstance.isGuestUser = false
                        let user  = UserModel(json: data["data"]["user"])
                        Constants.sharedInstance.USER = user
                        
                        let token = "Bearer \(data["data"]["token"])"
                        
                        DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                        DEFAULTS.synchronize()
                        
                        let code = data["data"]["verificationCode"].stringValue
                        let registrationToken = data["data"]["registrationToken"].stringValue
                        
                        let verificationVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.VALIDATION_VC) as! ValidationVC
                        verificationVC.code = code
                        self.navigationController?.pushViewController(verificationVC, animated: true)
                        
                    } else {
                        self.showToast(message: data["data"]["message"].stringValue)
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
        parameters["access_token"]    = access_token
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
                        self.showToast(message: data["data"]["errors"]["message"].stringValue)
                    }
                } catch {
                    self.showToast(message: error.localizedDescription)
                }
            case .failure(_):
                self.showToast(message: "Something went wrong")
            }
        })
    }
    
}

/* MARK:- Country Picker Delegate */
extension RegisterVC: CountryPickerViewDelegate, CountryPickerViewDataSource{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country){
        coutryCode         = country.code
        countryCodeTF.text = country.phoneCode
        self.country       = country.name
    }
}

extension RegisterVC:  GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let components = place.addressComponents {
            for addressComponent in components {
                for type in (addressComponent.types) {
                    switch(type){
                    case "locality":
                        self.cityTF.text = addressComponent.name
                    default:
                        break
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle Error
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}
