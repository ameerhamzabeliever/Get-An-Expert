//
//  OnboardingVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 25/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class OnboardingVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var onboardingCV     : UICollectionView!
    @IBOutlet weak var pageControlView  : UIView!
    @IBOutlet weak var loginButton      : UIButton!
    @IBOutlet weak var signUpButton     : UIButton!
    @IBOutlet weak var pageControl      : UIPageControl!
    
    /* MARK:- Properties */
    var onboardingData = [
        ["Flexible Time",
         "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
         "ob1"],
        ["Health Advice",
         "Chat and get health advice from experienced doctors.",
         "ob2"],
        ["Home Check-Up",
         "Samples are taken at home. Provides fast and accurate results.",
         "ob3"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}
/* MARK:- Methods */
extension OnboardingVC {
    
    func setupVC() {
        setlayout()
        registerNib()
    }
    
    func setlayout() {
        DispatchQueue.main.async {
            self.pageControlView.layer.cornerRadius = self.pageControlView.bounds.height / 2
            self.loginButton    .layer.cornerRadius = self.loginButton    .bounds.height / 10
            self.signUpButton   .layer.cornerRadius = self.signUpButton   .bounds.height / 10
        }
    }
    
    func registerNib(){
        self.onboardingCV.register(
            UINib(
                nibName: Constants.CVCells.ONBOARDING_CELL,
                bundle: nil
            )
            , forCellWithReuseIdentifier: Constants.CVCells.ONBOARDING_CELL
        )
    }
    
}

/* MARK:- Actions */
extension OnboardingVC {
    
    @IBAction func skipAction(_ sender: Any) {
        let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
        Constants.sharedInstance.isGuestUser = true
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    @IBAction func loginAction(_ sender: Any) {
        let loginVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.LOGIN_VC)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    @IBAction func signUpAction(_ sender: Any) {
        let signUpVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.REGISTER_VC)
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
}

/* MARK:- CollectionView Delegate and Datasource */
extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CVCells.ONBOARDING_CELL, for: indexPath) as! OnboardingCell
        let row  = indexPath.row
        let data = onboardingData[row]
        cell.setCell(Title: data[0], Description: data[1], Image: data[2])
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: onboardingCV.frame.width, height: onboardingCV.frame.height)
    }
    
}
