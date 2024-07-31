//
//  AllServicesVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 08/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllServicesVC: UIViewController {
    /* MARK:- Outlets */
    @IBOutlet weak var servicesCV : UICollectionView!
    
    /* MARK:- Properties */
    var services   : [FeaturedServices] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}

/* MARK:- Methods */
extension AllServicesVC {
    func setupVC() {
        registerNib()
    }
    
    func registerNib(){
        servicesCV.register(
            UINib(
                nibName: Constants.CVCells.SERVICE_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.SERVICE_CELL
        )
        getFeaturedServices("1")
    }
}

/* MARK:- Actions */
extension AllServicesVC {
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

/* MARK:- CollectionView Delegate and Datasource */
extension AllServicesVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
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
        
        let index    = indexPath.row
        cell.service = services[index]
        
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
extension AllServicesVC {
    func getFeaturedServices(_ pageNumber: String, language: String = "", location: String = ""){
        showSpinner(onView: view)
        
        NetworkManager.sharedInstance.getAllServices(pageNumber: pageNumber, language: language, location: location) {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data      = try JSON(data: response.data!)
                            self.services = data["services"].arrayValue.map({FeaturedServices(json: $0)})
                            
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
