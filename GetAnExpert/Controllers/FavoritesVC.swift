//
//  FavoritesVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class FavoritesVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var servicesCV : UICollectionView!
    
    /* MARK:- Properties */
    var services: [FeaturedServices] = []
    
    /* MARK:- Closures */
    var didNeedsRefresh: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVC()
    }
}

/* MARK:- Methods */
extension FavoritesVC {
    
    func setupVC() {
        registerNib()
        
        didNeedsRefresh = { [weak self] in
            guard let self = self else { return }
            
            self.getMyFavouritePackages()
        }
    }
    
    func registerNib(){
        self.servicesCV.register(
            UINib(
                nibName: Constants.CVCells.SERVICE_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.SERVICE_CELL
        )
        
        getMyFavouritePackages()
    }
}

/* MARK:- Actions */
extension FavoritesVC {
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

/* MARK:- CollectionView Delegate and Datasource */
extension FavoritesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.CVCells.SERVICE_CELL,
            for: indexPath
        ) as! ServiceCell
        
        let index       = indexPath.row
        cell.index      = index
        cell.service    = services[index]
        cell.refrenceVC = self
        
        cell.didTapCellButton = { [weak self] in
            guard let self = self else {return}
            
            let providerVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_DETAIL_VC
            ) as! ProviderDetailVC
            
            providerVC.userId     = self.services[index].user.id
            providerVC.identifier = "Services"
            
            self.navigationController?.pushViewController(providerVC, animated: true)
        }
        
        return cell
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let width  = servicesCV.frame.width
        let height = width * 0.5741
        return CGSize(width: width, height: height)
        
    }
    
}

/* MARK:- API Methods */
extension FavoritesVC {
    func getMyFavouritePackages(){
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getMyFavouritePackages {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            self.services.removeAll()
                            
                            let data      = try JSON(data: response.data!)
                            self.services = data["favourites"].arrayValue.map({FeaturedServices(json: $0)})
                        
                            self.servicesCV.reloadData()
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
