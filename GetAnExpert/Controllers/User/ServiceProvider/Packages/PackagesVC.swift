//
//  PackagesVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 11/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import SwiftyJSON
import YPImagePicker

class PackagesVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var packagesTV       : UITableView!
    @IBOutlet weak var newPackageButton : UIButton!
    
    /* MARK:- Properties */
    var packages: [PackagesModel] = []
    
    /* MARK:- Closures */
    var didNeedrefresh: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}

/* MARK:- Methods */
extension PackagesVC {
    
    func setupVC(){
        registerNibs()
        setLayout()
        
        didNeedrefresh = { [weak self] in
            guard let self = self else {return}
            self.getMyPackages()
        }
    }
    
    func registerNibs(){
        self.packagesTV.register(
            UINib(
                nibName: Constants.TVCells.PACKAGE_CELL,
                bundle : nil
            ),
            forCellReuseIdentifier: Constants.TVCells.PACKAGE_CELL
        )
        
        getMyPackages()
    }
    
    func setLayout() {
        DispatchQueue.main.async {
            self.newPackageButton.layer.cornerRadius = self.newPackageButton.bounds.height / 8
        }
    }
}

/* MARK:- Selector Methods */
extension PackagesVC {
    @objc func showMenu(_ sender : UIButton){
        sender.isSelected   = !sender.isSelected
        let indexPath       = IndexPath(row: sender.tag, section: 0)
        let cell            = packagesTV.cellForRow(at: indexPath) as! PackageCell
        if sender.isSelected {
            cell.menuView.alpha = 1.0
        } else {
            cell.menuView.alpha = 0.0
        }
    }
    
    @objc func didTapEdit(_ sender : UIButton){
        let addPackageVC    = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.ADD_PACKAGE_VC
        ) as! AddPackageVC
        
        addPackageVC.isUpdate   = true
        addPackageVC.package    = packages[sender.tag]
        addPackageVC.refrenceVC = self
            
        self.navigationController?.pushViewController(addPackageVC, animated: true)
    }
    
    @objc func didTapDelete(_ sender : UIButton){
        deleteMyPackage(packageId: packages[sender.tag].id)
    }
}
/* MARK:- Actions */
extension PackagesVC {
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPackageAction(_ sender: UIButton){
        let addPackageVC = MAIN_STORYBOARD.instantiateViewController(
            withIdentifier: Constants.ViewControllers.ADD_PACKAGE_VC
        ) as! AddPackageVC
        
        addPackageVC.refrenceVC = self
        
        self.navigationController?.pushViewController(addPackageVC, animated: true)
    }
}
/* MARK:- TableView Delegate & Datasource */
extension PackagesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCells.PACKAGE_CELL) as! PackageCell
        
        let row               = indexPath.row
        cell.package          = packages[row]
        cell.menuButton.alpha = 1.0
        
        ///Setting up tags
        cell.menuButton.tag   = row
        cell.editButton.tag   = row
        cell.deleteButton.tag = row
        
        ///Actions
        cell.menuButton.addTarget(
            self,
            action: #selector(showMenu(_:)),
            for: .touchUpInside
        )
        
        cell.editButton.addTarget(
            self,
            action: #selector(didTapEdit(_:)),
            for: .touchUpInside
        )
        
        cell.deleteButton.addTarget(
            self,
            action: #selector(didTapDelete(_:)),
            for: .touchUpInside
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.packagesTV.bounds.height / 5.4
    }
    
}

/* MARK:- API Methods */
extension PackagesVC {
    func getMyPackages(){
        showSpinner(onView: view)
        NetworkManager.sharedInstance.getMyPackages {  [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data = try JSON(data: response.data!)
                            self.packages = data["services"].arrayValue.map({PackagesModel(json: $0)})
                            
                            self.packagesTV.reloadData()
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
    
    func deleteMyPackage(packageId: String){
        showSpinner(onView: view)
        NetworkManager.sharedInstance.deleteMyPackage(packageId: packageId) { [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        self.getMyPackages()
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
