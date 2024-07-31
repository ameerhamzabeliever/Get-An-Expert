//
//  AllExpertsVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 08/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllExpertsVC: UIViewController {
    /* MARK:- Outlets */
    @IBOutlet weak var expertsCV  : UICollectionView!
    @IBOutlet weak var titleLabel : UILabel!
    
    /* MARK:- Properties */
    var experts       : [UserModel]         = []
    var category      : CategoriesModel?
    var categoryUsers : CategoryUsersModel?
    
    var isFeaturedExperts: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}

/* MARK:- Methods */
extension AllExpertsVC {
    
    func setupVC() {
        registerNib()
        if isFeaturedExperts {
            titleLabel.text = "Featured Experts"
            getFeaturedExperts("1")
        } else {
            if let category = self.category {
                titleLabel.text = "Expert \(category.name)"
                
                getCategoryUsers(category.id)
            }
        }
    }
    func registerNib(){
        self.expertsCV.register(
            UINib(
                nibName: Constants.CVCells.EXPERTS_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.EXPERTS_CELL
        )
    }
}
/* MARK:- Actions */
extension AllExpertsVC {
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
/* MARK:- CollectionView Delegate and Datasource */
extension AllExpertsVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if experts.count == 0 {
            collectionView.setEmptyMessage("Sorry, there are no experts in this category yet.")
        } else {
            collectionView.restore()
        }
        
        return experts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.CVCells.EXPERTS_CELL,
            for: indexPath
        ) as! ExpertsCell
        
        let index         = indexPath.row
        cell.categoryUser = experts[index]
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width  = (expertsCV.frame.width * 0.9)/2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let providerVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.PROVIDER_DETAIL_VC
        ) as! ProviderDetailVC
        
        let index         = indexPath.row
        providerVC.userId = experts[index].id
        
        self.navigationController?.pushViewController(providerVC, animated: true)
    }
    
}

/* MARK:- API Methods */
extension AllExpertsVC {
    func getCategoryUsers(_ categoryId: String) {
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getCategoryUsers(categoryId: categoryId) { [weak self] (response) in
            guard let self = self else { return }
            self.removeSpinner()
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data           = try JSON(data: response.data!)
                            self.categoryUsers = CategoryUsersModel(json: data["category"])
                            self.experts       = self.categoryUsers?.users ?? []
                            
                            self.expertsCV.reloadData()
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
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getFeaturedExperts(pageNumber: pageNumber, language: language, location: location) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data     = try JSON(data: response.data!)
                            self.experts = data["experts"].arrayValue.map({UserModel(json: $0)})
                            
                            self.expertsCV.reloadData()
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
