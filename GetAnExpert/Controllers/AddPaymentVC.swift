//
//  AddPaymentVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Braintree

class AddPaymentVC: UIViewController {
    /* MARK:- Outlets */
    @IBOutlet weak var cardImage        : UIImageView!
    @IBOutlet weak var cardsTV          : UITableView!
    @IBOutlet weak var dontHaveLabel    : UILabel!
    @IBOutlet weak var saveButtonView   : UIView!
    
    /* MARK:- Properties */
    var cardsCount = 0
    var braintreeClient : BTAPIClient!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

/* MARK:- Methods */
extension AddPaymentVC {
    
    func setupVC() {
        brainTreeSetup()
        registerNib()
        setLayout()
    }
    
    func setLayout(){
        DispatchQueue.main.async {
            self.saveButtonView.layer.cornerRadius = self.saveButtonView.bounds.height / 8
        }
    }
    
    func registerNib(){
        self.cardsTV.register(
            UINib(
                nibName: Constants.TVCells.CARD_CELL,
                bundle: nil
            ), forCellReuseIdentifier: Constants.TVCells.CARD_CELL
        )
    }
    func brainTreeSetup(){
        braintreeClient = BTAPIClient(authorization: "sandbox_9qfnmbsx_46cx43ygrqyjwxkc")!
    }
    func buyAction() {
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        let request = BTPayPalRequest(amount: "2.32")
        request.currencyCode = "USD" // Optional; see BTPayPalRequest.h for more options
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                print(tokenizedPayPalAccount)
            } else if let error = error {
                print(error)
            } else {
                // Buyer canceled payment approval
            }
        }
    }
}

/* MARK:- Selector Methods */
extension AddPaymentVC {
    @objc func selectCard(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        let indexPath     = IndexPath(row: sender.tag, section: 0)
        let _             = cardsTV.cellForRow(at: indexPath) as! CardCell
    }
}

/* MARK:- Actions */
extension AddPaymentVC {
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addCardAction(_ sender: Any) {
        buyAction()
        //        self.cardsCount = 1
        //        self.cardsTV.reloadData()
        //        let newCardVC   = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.NEW_CARD_VC)
        //        self.navigationController?.pushViewController(newCardVC, animated: true)
    }
}

/* MARK:- TableView Delegate & Datasource */
extension AddPaymentVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cardsCount == 0 {
            self.cardImage.alpha     = 1.0
            self.dontHaveLabel.alpha = 1.0
        } else {
            self.cardImage.alpha     = 0.0
            self.dontHaveLabel.alpha = 0.0
        }
        return cardsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCells.CARD_CELL) as! CardCell
        cell.selectButton.alpha = 0.0
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cardsTV.bounds.height / 6.45
    }
    
}
/* MARK:- BrainTree Presenting Delegate */
/// A required delegate that is responsible for presenting and dismissing an SFSafariViewController on iOS 9+ devices.
extension AddPaymentVC : BTViewControllerPresentingDelegate {
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
}

/* MARK:- BrainTree Switch Delegate */
/// An optional delegate that receives messages when switching to the PayPal website via Mobile Safari. This can be used to present/dismiss a loading activity indicator.
extension AddPaymentVC : BTAppSwitchDelegate {
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
}
