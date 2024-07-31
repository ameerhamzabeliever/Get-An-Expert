//
//  ProviderDetailVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 09/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProviderDetailVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var providerImage     : UIImageView!
    
    @IBOutlet weak var providerDetail    : UITextView!
    @IBOutlet weak var educationTextView : UITextView!
    
    @IBOutlet weak var providerName      : UILabel!
    @IBOutlet weak var specialityLbl     : UILabel!
    @IBOutlet weak var locationLbl       : UILabel!
    @IBOutlet weak var brieflocationLbl  : UILabel!
    @IBOutlet weak var phoneLbl          : UILabel!
    @IBOutlet weak var ratingLbl         : UILabel!
    @IBOutlet weak var writeReviewLable  : UILabel!
    
    @IBOutlet weak var descriptionButton : UIButton!
    @IBOutlet weak var servicesButton    : UIButton!
    @IBOutlet weak var reviewsButton     : UIButton!
    @IBOutlet weak var educationsButton  : UIButton!
    @IBOutlet weak var giveReviewButton  : UIButton!
    
    @IBOutlet weak var descriptionView   : UIView!
    @IBOutlet weak var servicesView      : UIView!
    @IBOutlet weak var reviewsView       : UIView!
    @IBOutlet weak var educationsView    : UIView!
    @IBOutlet weak var ratingView        : UIView!
    
    @IBOutlet weak var packagesTV        : UITableView!
    @IBOutlet weak var reviewsTV         : UITableView!
    
    /* MARK:- Properties */
    var user       : UserModel     = UserModel()
    var userId     : String        = "" ///The user whose profile is to be opened.
    var service_Id : String        = ""
    var identifier : String        = ""
    var ratings    : [RatingModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}

/* MARK:- Methods */
extension ProviderDetailVC {
    
    func setupVC(){
        registerNibs()
        setLayout()
        getValues()
    }
    
    func registerNibs(){
        packagesTV.register(
            UINib(
                nibName: Constants.TVCells.PACKAGE_CELL,
                bundle : nil
            ),
            forCellReuseIdentifier: Constants.TVCells.PACKAGE_CELL
        )
        reviewsTV.register(
            UINib(
                nibName: Constants.TVCells.REVIEW_CELL,
                bundle : nil
            ),
            forCellReuseIdentifier: Constants.TVCells.REVIEW_CELL
        )
    }
    
    func getValues(){
        getOtherUserProfile(userId)
        getOtherUserRatings(userId)
    }
    
    func setLayout(){
        DispatchQueue.main.async {
            self.providerImage.layer.cornerRadius = self.providerImage.bounds.height / 8
            self.specialityLbl.layer.cornerRadius = self.specialityLbl.bounds.height / 8
            self.ratingView   .layer.cornerRadius = self.ratingView   .bounds.height / 2
            self.descriptionButton.roundCorners(
                corners: [.topLeft, .bottomLeft],
                radius: self.descriptionButton.bounds.height / 2
            )
            self.reviewsButton.roundCorners(
                corners: [.topRight, .bottomRight],
                radius: self.reviewsButton.bounds.height / 2
            )
        }
        
        if identifier != "" {
            descriptionButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            servicesButton.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.4431372549, blue: 0.4196078431, alpha: 1)
            changeTab(identifier)
        }
    }
    
    func populateView(){
        let placeHolder = UIImage(named: "placeholder")
        let stringUrl   = user.image.replacingOccurrences(of: " ", with: "%20")
        
        if let url = URL(string: stringUrl) {
            providerImage.kf.setImage(with: url, placeholder: placeHolder)
        }
        
        providerName.text  = user.name
        specialityLbl.text = user.category.name
        
        if user.address.country != "" {
            brieflocationLbl.text   = "\(user.address.city),\(user.address.country)"
        } else {
            brieflocationLbl.text   = "\(user.address.city)"
        }
        
        if user.rating != 0.0 {
            ratingLbl.text = "\(Helper.precise(doubleValue: user.rating, ByUnits: 10))"
        } else {
            ratingLbl.text = "N/A"
        }
        
        if user.address.fullAddress != "" {
            locationLbl.text = user.address.fullAddress
        } else {
            if user.address.country != "" {
                locationLbl.text = "\(user.address.city),\(user.address.country)"
            } else {
                locationLbl.text = "\(user.address.city)"
            }
        }
        
        phoneLbl.text          = user.phone
        providerDetail.text    = user.providerInfo.about
        educationTextView.text = user.providerInfo.degree
        
        packagesTV.reloadData()
    }
    
    func changeTab(_ identifier: String) {
        if identifier == "Description" {
            descriptionButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            servicesButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            reviewsButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            educationsButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            
            servicesButton.backgroundColor          = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            reviewsButton.backgroundColor           = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            educationsButton.backgroundColor        = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            descriptionView.alpha                   = 1.0
            servicesView.alpha                      = 0.0
            reviewsView.alpha                       = 0.0
            educationsView.alpha                    = 0.0
            
        } else if identifier == "Reviews" {
            reviewsButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            servicesButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            descriptionButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            educationsButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            
            servicesButton.backgroundColor          = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            descriptionButton.backgroundColor       = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            educationsButton.backgroundColor        = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            descriptionView.alpha                   = 0.0
            servicesView.alpha                      = 0.0
            reviewsView.alpha                       = 1.0
            educationsView.alpha                    = 0.0
            
        } else if identifier == "Services" {
            servicesButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            reviewsButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            descriptionButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            educationsButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            
            descriptionButton.backgroundColor       = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            reviewsButton.backgroundColor           = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            educationsButton.backgroundColor        = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            descriptionView.alpha                   = 0.0
            servicesView.alpha                      = 1.0
            reviewsView.alpha                       = 0.0
            educationsView.alpha                    = 0.0
        } else {
            educationsButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            reviewsButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            descriptionButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            servicesButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            
            descriptionButton.backgroundColor       = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            reviewsButton.backgroundColor           = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            servicesButton.backgroundColor          = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            descriptionView.alpha                   = 0.0
            servicesView.alpha                      = 0.0
            reviewsView.alpha                       = 0.0
            educationsView.alpha                    = 1.0
        }
    }
}

/* MARK:- Actions */
extension ProviderDetailVC {
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func socialAction(_ sender: UIButton){
        if sender.accessibilityIdentifier == "Facebook" {
            
        } else if sender.accessibilityIdentifier == "Linkedin" {
            
        } else if sender.accessibilityIdentifier == "Twitter" {
            
        }
    }
    
    @IBAction func tabAction(_ sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.4431372549, blue: 0.4196078431, alpha: 1)
        changeTab(sender.accessibilityIdentifier ?? "")
    }
    
    @IBAction func reviewAction(_ sender: UIButton){
        let reviewVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.REVIEW_VC) as! ReviewVC
        reviewVC.service_Id = service_Id
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
}

/* MARK:- TableView Delegate & Datasource */
extension ProviderDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == packagesTV {
            return user.services.count
        } else {
            return self.ratings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == packagesTV {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.TVCells.PACKAGE_CELL
            ) as! PackageCell
            
            let index                = indexPath.row
            cell.package             = user.services[index]
            cell.bookNowButton.alpha = 1.0
            
            cell.didTapBookNow = { [weak self] index in
                guard let self = self else {return}
                
                let selectSlotsVC = SelectSlotsVC(
                    nibName : Constants.ViewControllers.SELECT_SLOTS_VC,
                    bundle  : nil
                )
                
                selectSlotsVC.userId    = self.user.id
                selectSlotsVC.serviceId = self.user.services[index].id
                
                self.navigationController?.pushViewController(selectSlotsVC, animated: true)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.TVCells.REVIEW_CELL
            ) as! ReviewCell
            
            let index   = indexPath.row
            cell.rating = ratings[index]
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == packagesTV {
            return self.packagesTV.bounds.height / 3
        } else {
            return self.reviewsTV.bounds.height / 3
        }
    }
    
}

/* MARK:- API Methods */
extension ProviderDetailVC {
    func getOtherUserProfile(_ otherUserId: String) {
        self.showSpinner(onView: view)
        NetworkManager.sharedInstance.getOtherUserProfile(otherUserId: otherUserId) { [weak self] (response) in
            guard let self = self else {return}
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data  = try JSON(data: response.data!)
                            self.user = UserModel(json: data["user"])
                            
                            self.populateView()
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
        }
    }
    
    func getOtherUserRatings(_ otherUserId: String) {
        NetworkManager.sharedInstance.getOtherUserRatings(otherUserId: otherUserId) { [weak self] (response) in
            guard let self = self else {return}
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data     = try JSON(data: response.data!)
                            let status = data["status"].boolValue
                            if status == true {
                                self.giveReviewButton.alpha = 1.0
                                self.writeReviewLable.alpha = 1.0
                            }
                            self.ratings = data["ratings"].arrayValue.map({ RatingModel(json: $0) })
                            
                            self.reviewsTV.reloadData()
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
        }
    }
}
