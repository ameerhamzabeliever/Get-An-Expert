//
//  HomeVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import DropDown
import SwiftyJSON
import GooglePlaces

class HomeVC: UIViewController, UITextFieldDelegate {
    /* MARK:- Outlets */
    @IBOutlet weak var searchView            : UIView!
    @IBOutlet weak var languageView          : UIView!
    @IBOutlet weak var categoryView          : UIView!
    @IBOutlet weak var featuredExpertsView   : UIView!
    @IBOutlet weak var featuredServicesView  : UIView!
    
    @IBOutlet weak var categoryCV            : UICollectionView!
    @IBOutlet weak var featuredExpertsCV     : UICollectionView!
    @IBOutlet weak var featuredServicesCV    : UICollectionView!
    
    @IBOutlet weak var languageLabel         : UILabel!
    @IBOutlet weak var locationLabel         : UILabel!
    @IBOutlet weak var searchingTF           : UITextField!
    
    var searchData = ""
    var isSearching = false
    
    
    /* MARK:- Properties */
    var experts    : [UserModel]        = []
    var services   : [FeaturedServices] = []
    var languages  : [LanguagesModel]   = []
    var categories : [CategoriesModel]  = []
    var searched_Categories : [CategoriesModel]  = []
    var searched_Experts    : [UserModel]        = []
    var searched_Services   : [FeaturedServices] = []
    
    var selectedLanguage: String = ""
    var selectedLocation: String = ""
    
    let languageDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiCalls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isSearching = false
    }
}

/* MARK:- Methods */
extension HomeVC {
    
    func setupVC() {
        // Gender DropDown init
        languageDropDown.anchorView   = languageView
        languageDropDown.bottomOffset = CGPoint(x: 0, y:(languageDropDown.anchorView?.plainView.bounds.height)!)
        languageDropDown.direction    = .bottom
        languageDropDown.dataSource   = []
        languageDropDown.width        = SCREEN_WIDTH * 0.3
        
        searchingTF.delegate = self
        searchingTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setlayout()
        registerNib()
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.searchView.layer.cornerRadius   = self.searchView.bounds.height / 2
            self.categoryView.layer.cornerRadius = self.categoryView.bounds.height / 10
            self.featuredExpertsView.layer.cornerRadius = self.featuredExpertsView.bounds.height / 10
            self.featuredServicesView.layer.cornerRadius = self.featuredServicesView.bounds.height / 10
            
            Helper.setShadow(layer: self.categoryView.layer, shadowRadius: 2, shadowOpacity: 1, shadowColor: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), shadowOffset: CGSize(width: 0, height: 1.0))
            Helper.setShadow(layer: self.featuredExpertsView.layer, shadowRadius: 4, shadowOpacity: 1, shadowColor: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), shadowOffset: CGSize(width: 0, height: 2.0))
            Helper.setShadow(layer: self.featuredServicesView.layer, shadowRadius: 6, shadowOpacity: 1, shadowColor: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), shadowOffset: CGSize(width: 0, height: 2.0))
            
        }
    }
    
    func registerNib(){
        self.categoryCV.register(
            UINib(
                nibName: Constants.CVCells.CATEGORY_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.CATEGORY_CELL
        )
        self.featuredExpertsCV.register(
            UINib(
                nibName: Constants.CVCells.EXPERTS_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.EXPERTS_CELL
        )
        self.featuredServicesCV.register(
            UINib(
                nibName: Constants.CVCells.SERVICE_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.SERVICE_CELL
        )
    }
    
    func apiCalls(){
        getFeaturedCategories("1")
        getFeaturedExperts("1")
        getFeaturedServices("1")
        getAllLanguages()
    }
}

/* MARK:- Actions */
extension HomeVC {
    
    @IBAction func allCategoriesAction(_ sender: UIButton){
        let allCategoriesVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.ALL_CATEGORIES_VC)
        self.navigationController?.pushViewController(allCategoriesVC, animated: true)
    }
    @IBAction func allExpertsAction(_ sender: UIButton){
        let allExpertsVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.ALL_EXPERTS_VC
        ) as! AllExpertsVC
        
        allExpertsVC.isFeaturedExperts = true
        
        self.navigationController?.pushViewController(allExpertsVC, animated: true)
    }
    @IBAction func allServicesAction(_ sender: UIButton){
        let allServicesVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.ALL_SERVICES_VC)
        self.navigationController?.pushViewController(allServicesVC, animated: true)
    }
    @IBAction func languageAction(_ sender: UIButton){
        languageDropDown.show()
        languageDropDown.selectionAction = { [unowned self] ( index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.languageLabel.text = item
            self.selectedLanguage   = self.languages[index].id
            
            if let location = locationLabel.text, locationLabel.text != "City" {
                getFeaturedExperts("1", language: self.selectedLanguage, location: location)
                getFeaturedServices("1", language: self.selectedLanguage, location: location)
            } else {
                getFeaturedExperts("1", language: self.selectedLanguage)
                getFeaturedServices("1", language: self.selectedLanguage)
            }
        }
    }
    @IBAction func locationAction(_ sender: UIButton){
        let acController      = GMSAutocompleteViewController()
        acController.delegate = self
        let filter            = GMSAutocompleteFilter()
//        filter.country        = "uk|country:aus|country:usa|country:ca"
        filter.country        = "usa|country:ca"
        
        acController.autocompleteFilter = filter
        
        present(acController, animated: true, completion: nil)
    }
    
    @IBAction func didTapSearch(_ sender: UIButton){
        searchData = searchingTF.text ?? ""
        searched_Categories.removeAll()
        searched_Experts.removeAll()
        searched_Services.removeAll()
        if searchData == ""{
            self.showAlert(message: "Enter some data to search")
        }
        else{
            isSearching = true
            for i in 0..<categories.count {
                if self.categories[i].name == self.searchData{
                    searched_Categories.append(categories[i])
                }
            }
                for i in 0..<experts.count{
                    if self.experts[i].category.name == self.searchData{
                        searched_Experts.append(experts[i])
                    }
                }
                for i in 0..<services.count{
                    if self.services[i].user.category.name == self.searchData{
                        searched_Services.append(services[i])
                    }
                }
            
            let searchResultsVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.SEARCH_RESULTS_VC
            ) as! SearchResultsVC
            
            searchResultsVC.searched_Categories = searched_Categories
            searchResultsVC.searched_Experts    = searched_Experts
            searchResultsVC.searched_Services   = searched_Services
            
            self.navigationController?.pushViewController(searchResultsVC, animated: true)
        }
        
    }
    
}

/* MARK:- CollectionView Delegate and Datasource */
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCV {
            return categories.count
        } else if collectionView == featuredExpertsCV {
            return experts.count
        } else {
            return services.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        if collectionView == featuredExpertsCV {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.CVCells.EXPERTS_CELL,
                for: indexPath
            ) as! ExpertsCell
            
            let index = indexPath.row
            cell.categoryUser = experts[index]
            
            return cell
        } else if collectionView == categoryCV {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.CVCells.CATEGORY_CELL,
                for: indexPath
            ) as! CategoryCell
            
            let index     = indexPath.row
            cell.category = categories[index]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.CVCells.SERVICE_CELL,
                for: indexPath
            ) as! ServiceCell
            
            let index    = indexPath.row
            cell.index   = index
            cell.service = services[index]
            cell.didTapCellButton = {
                let providerVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_DETAIL_VC
                ) as! ProviderDetailVC
                providerVC.userId     = self.services[index].user.id
                providerVC.service_Id = self.services[index].id
                providerVC.identifier = "Services"
                
                self.navigationController?.pushViewController(providerVC, animated: true)
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == featuredExpertsCV {
            return CGSize(width: (featuredExpertsCV.frame.width * 0.9)/3, height: featuredExpertsCV.frame.height)
        } else if collectionView == categoryCV {
            return CGSize(width: (categoryCV.frame.width * 0.9)/3, height: categoryCV.frame.height)
        } else {
            return CGSize(width: (featuredServicesCV.frame.width * 0.9)/1.3, height: featuredServicesCV.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCV {
            let allExpertsVC = MAIN_STORYBOARD.instantiateViewController(
                withIdentifier: Constants.ViewControllers.ALL_EXPERTS_VC
            ) as! AllExpertsVC
            
            let index             = indexPath.row
            allExpertsVC.category = self.categories[index]
            
            self.navigationController?.pushViewController(allExpertsVC, animated: true)
        } else if collectionView == featuredExpertsCV {
            let providerVC = MAIN_STORYBOARD.instantiateViewController(
                withIdentifier: Constants.ViewControllers.PROVIDER_DETAIL_VC
            ) as! ProviderDetailVC
            
            let index         = indexPath.row
                providerVC.userId = experts[index].id
                providerVC.service_Id = services[index].id
            
            self.navigationController?.pushViewController(providerVC, animated: true)
        }
    }
    
}

/* MARK:- API Methods */
extension HomeVC {
    func getAllLanguages(){
        NetworkManager.sharedInstance.getAllLanguages { [weak self] (response) in
            guard let self = self else { return }
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data        = try JSON(data: response.data!)
                            self.languages  = data["languages"].arrayValue.map({LanguagesModel(json: $0)})
                            
                            var languageDropDownDatasource: [String] = []
                            self.languages.forEach { (language) in
                                languageDropDownDatasource.append(language.name)
                            }
                            
                            self.languageDropDown.dataSource = languageDropDownDatasource
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
    
    func getFeaturedCategories(_ pageNumber: String){
        self.showSpinner(onView: categoryView, identifier: "categoryView", title: "Loading...")
        
        NetworkManager.sharedInstance.getFeaturedCategories(pageNumber: pageNumber) { [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner(identifier: "categoryView")
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data        = try JSON(data: response.data!)
                            self.categories = data["categories"].arrayValue.map({CategoriesModel(json: $0)})
                            
                            self.categoryCV.reloadData()
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
    
    func getFeaturedExperts(_ pageNumber: String, language: String = "", location: String = "") {
        self.showSpinner(onView: featuredExpertsView, identifier: "featuredExpertsView", title: "Loading...")
        
        NetworkManager.sharedInstance.getFeaturedExperts(pageNumber: pageNumber, language: language, location: location) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner(identifier: "featuredExpertsView")
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data     = try JSON(data: response.data!)
                            self.experts = data["experts"].arrayValue.map({UserModel(json: $0)})
                            
                            self.featuredExpertsCV.reloadData()
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
    
    func getFeaturedServices(_ pageNumber: String, language: String = "", location: String = ""){
        self.showSpinner(onView: featuredServicesView, identifier: "featuredServicesView", title: "Loading...")
        
        NetworkManager.sharedInstance.getAllServices(pageNumber: pageNumber, language: language, location: location) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner(identifier: "featuredServicesView")
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data      = try JSON(data: response.data!)
                            self.services = data["services"].arrayValue.map({FeaturedServices(json: $0)})
                            
                            self.featuredServicesCV.reloadData()
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

/* MARK:- AutoComplete Places */

/// Delegate
extension HomeVC : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let components = place.addressComponents {
            for addressComponent in components {
                for type in (addressComponent.types) {
                    switch(type){
                    case "locality":
                        locationLabel.text = addressComponent.name
                        
                        if self.selectedLanguage != "" {
                            getFeaturedExperts(
                                "1",
                                language: self.selectedLanguage,
                                location: addressComponent.name
                            )
                            getFeaturedServices(
                                "1",
                                language: self.selectedLanguage,
                                location: addressComponent.name
                            )
                        } else {
                            getFeaturedExperts("1", location: addressComponent.name)
                            getFeaturedServices("1", location: addressComponent.name)
                        }
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

extension HomeVC{
    @objc func textFieldDidChange(_ textField: UITextField){
        if textField.text == "" {
            isSearching = false
            categories.removeAll()
            services.removeAll()
            experts.removeAll()
            searched_Categories.removeAll()
            searched_Experts.removeAll()
            searched_Services.removeAll()
            apiCalls()
        }
    }
}
