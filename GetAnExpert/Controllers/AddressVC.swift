//
//  AddressVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 06/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces

class AddressVC: UIViewController {
    /* MARK:- Outlets */
    @IBOutlet weak var searchView     : UIView!
    @IBOutlet weak var coutryView     : UIView!
    @IBOutlet weak var cityView       : UIView!
    @IBOutlet weak var postalCodeView : UIView!
    @IBOutlet weak var streetView     : UIView!
    
    @IBOutlet weak var searchTextField      : UITextField!
    @IBOutlet weak var countryTexField      : UITextField!
    @IBOutlet weak var cityTextfield        : UITextField!
    @IBOutlet weak var postalCodeTextfield  : UITextField!
    @IBOutlet weak var streetTextfield      : UITextField!
    
    @IBOutlet weak var saveButton       : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
}

/* MARK:- Methods */
extension AddressVC {
    
    func setupVC() {
        setlayout()
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.saveButton.layer.cornerRadius     = self.saveButton.bounds.height     / 10
            self.searchView.layer.cornerRadius     = self.searchView.bounds.height     / 10
            self.coutryView.layer.cornerRadius     = self.coutryView.bounds.height     / 10
            self.cityView.layer.cornerRadius       = self.cityView.bounds.height       / 10
            self.postalCodeView.layer.cornerRadius = self.postalCodeView.bounds.height / 10
            self.streetView.layer.cornerRadius     = self.streetView.bounds.height     / 10
        }
    }
    func loadData(){
        if let user = Constants.sharedInstance.USER {
            self.countryTexField.text     = user.address.country
            self.cityTextfield.text       = user.address.city
            self.postalCodeTextfield.text = user.address.postalCode
            self.streetTextfield.text     = user.address.street
        }
    }
}

/* MARK:- Actions */
extension AddressVC {
    
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func searchAdressAction(_ sender: UIButton){
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.country = "uk|country:aus|country:usa|country:ca"
        acController.autocompleteFilter = filter
        present(acController, animated: true, completion: nil)
    }
    @IBAction func saveAddressAction(_ sender: UIButton){
        updateAddress()
    }
}

/* MARK:- Api Methods */
extension AddressVC {
    func updateAddress() {
        guard let country = countryTexField.text, country != "" else {
            self.showAlert(message: "Country Field is Required")
            return
        }
        guard let city = cityTextfield.text, city != "" else {
            self.showAlert(message: "City Field is Required")
            return
        }
        guard let postalCode = postalCodeTextfield.text, postalCode != "" else {
            self.showAlert(message: "Enter your Postal Code Please")
            return
        }
        guard let street = streetTextfield.text, street != "" else {
            self.showAlert(message: "Fill your missing Address in Street Field")
            return
        }
        var parameters : [String : Any] = [:]
        
        parameters["country"]     = country
        parameters["city"]        = city
        parameters["postalCode"]  = postalCode
        parameters["street"]      = street
        parameters["fullAddress"] = "\(street), \(city), \(country)"
        
        self.showSpinner(onView: self.view, title: "Updating...")
        NetworkManager.sharedInstance.updateAddress(param: parameters) {
            (response) in
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
                        
                        self.navigationController?.popViewController(animated: true)
                        
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
}
/* MARK:- AutoComplete Places Delegates */
extension AddressVC : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let components = place.addressComponents {
            for addressComponent in components {
                for type in (addressComponent.types) {
                    switch(type){
                    case "locality":
                        self.cityTextfield.text       = addressComponent.name
                    case "route":
                        self.streetTextfield.text     = addressComponent.name
                    case "country":
                        self.countryTexField.text     = addressComponent.name
                    case "postal_code":
                        self.postalCodeTextfield.text = addressComponent.name
                    default:
                        break
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    func viewController(
        _ viewController: GMSAutocompleteViewController,
        didFailAutocompleteWithError error: Error
    ) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}
