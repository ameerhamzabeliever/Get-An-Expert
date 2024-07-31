//
//  AllExpertCategoriesVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 08/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllExpertCategoriesVC: UIViewController {
    /* MARK:- Outlets */
    @IBOutlet weak var categoriesCV : UICollectionView!
    
    /* MARK:- Properties */
    var categories : [CategoriesModel]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}

/* MARK:- Methods */
extension AllExpertCategoriesVC {
    
    func setupVC() {
        registerNib()
    }
    
    func registerNib(){
        self.categoriesCV.register(
            UINib(
                nibName: Constants.CVCells.CATEGORY_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.CATEGORY_CELL
        )
        
        getFeaturedCategories("1")
    }
}

/* MARK:- Actions */
extension AllExpertCategoriesVC {
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

/* MARK:- CollectionView Delegate and Datasource */
extension AllExpertCategoriesVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.CVCells.CATEGORY_CELL,
            for: indexPath
        ) as! CategoryCell
        
        let index     = indexPath.row
        cell.category = categories[index]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (categoriesCV.frame.width * 0.9)/2
        let height = width * 1.2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let allExpertsVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.ALL_EXPERTS_VC
        ) as! AllExpertsVC
        
        let index             = indexPath.row
        allExpertsVC.category = self.categories[index]
        
        self.navigationController?.pushViewController(allExpertsVC, animated: true)
    }
    
}

extension AllExpertCategoriesVC {
    func getFeaturedCategories(_ pageNumber: String){
        showSpinner(onView: view, identifier: "categoryView", title: "Loading...")
        
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
                            
                            self.categoriesCV.reloadData()
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
