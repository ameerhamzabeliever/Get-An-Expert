//
//  SearchResultsVC.swift
//  GetAnExpert
//
//  Created by Hamza's Mac on 24/05/2021.
//  Copyright © 2021 CodesBinary. All rights reserved.
//

import UIKit

class SearchResultsVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var categoryView          : UIView!
    @IBOutlet weak var featuredExpertsView   : UIView!
    @IBOutlet weak var featuredServicesView  : UIView!
    
    @IBOutlet weak var categoryCV            : UICollectionView!
    @IBOutlet weak var featuredExpertsCV     : UICollectionView!
    @IBOutlet weak var featuredServicesCV    : UICollectionView!
    
    /* MARK:- Properties */
    var searched_Categories : [CategoriesModel]  = []
    var searched_Experts    : [UserModel]        = []
    var searched_Services   : [FeaturedServices] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
    }
}
/* MARK:- Extensions */
extension SearchResultsVC{
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
}
/* MARK:- CollectionView Delegate and Datasource */
extension SearchResultsVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCV {
            return searched_Categories.count
        }
        else if collectionView == featuredExpertsCV {
            return searched_Experts.count
        }
        else {
            return searched_Services.count
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
            cell.categoryUser = searched_Experts[index]
            return cell
        } else if collectionView == categoryCV {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.CVCells.CATEGORY_CELL,
                for: indexPath
            ) as! CategoryCell
            
            let index     = indexPath.row
            cell.category = searched_Categories[index]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.CVCells.SERVICE_CELL,
                for: indexPath
            ) as! ServiceCell
            
            let index    = indexPath.row
            cell.index   = index
            cell.service = searched_Services[index]
            
            cell.didTapCellButton = {
                let providerVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_DETAIL_VC
                ) as! ProviderDetailVC
                providerVC.userId     = self.searched_Services[index].user.id
                providerVC.service_Id = self.searched_Services[index].id
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
            allExpertsVC.category = self.searched_Categories[index]
            self.navigationController?.pushViewController(allExpertsVC, animated: true)
        } else if collectionView == featuredExpertsCV {
            let providerVC = MAIN_STORYBOARD.instantiateViewController(
                withIdentifier: Constants.ViewControllers.PROVIDER_DETAIL_VC
            ) as! ProviderDetailVC
            
            let index         = indexPath.row
            providerVC.userId = searched_Experts[index].id
            providerVC.service_Id = searched_Services[index].id
            
            self.navigationController?.pushViewController(providerVC, animated: true)
        }
    }
    
}

/* MARK:- Actions */
extension SearchResultsVC{
    @IBAction func didTapBack(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
