//
//  ReviewVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Cosmos
import SwiftyJSON

class ReviewVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var ratingView       : CosmosView!
    @IBOutlet weak var reviewView       : UIView!
    @IBOutlet weak var sendButtonView   : UIView!
    @IBOutlet weak var reviewTextView   : UITextView!
    
    var service_Id : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
}

/* MARK:- Methods */
extension ReviewVC {
    
    func setupVC() {
        /// Initilizing TextView Placeholder
        reviewTextView.text      = "Write your review here"
        reviewTextView.textColor = .lightGray
        setLayout()
    }
    func setLayout(){
        DispatchQueue.main.async {
            self.reviewView    .layer.cornerRadius = self.reviewView    .bounds.height / 8
            self.sendButtonView.layer.cornerRadius = self.sendButtonView.bounds.height / 8
        }
    }
}


/* MARK:- Actions */
extension ReviewVC {
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendAction(_ sender: Any) {
        guard let review = reviewTextView.text, review != "Write your review here" else {
            self.showAlert(message: "Please enter review")
            return
        }
        
        let rating = ratingView.rating
                
        let parameters: [String: Any] = [
            "content" : review,
            "stars"   : rating
        ]
        sendReviewAndRatings(service_Id, parameters)
    }
    
}

/* MARK:- API Methods */
extension ReviewVC {
    func sendReviewAndRatings(_ serviceId: String, _ parameters: [String: Any]) {
        showSpinner(onView: view)
        NetworkManager.sharedInstance.sendRatingAndReview(
            serviceId : serviceId,
            parameters: parameters
        ) { [weak self] (response) in
            guard let self = self else { return }
            
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let _ = try JSON(data: response.data!)
                    
                            self.navigationController?.popViewController(animated: true)
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

/* MARK:- Text View */

/// Delegate
extension ReviewVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text      = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text      = "Write your review here"
            textView.textColor = .lightGray
        }
    }
}
