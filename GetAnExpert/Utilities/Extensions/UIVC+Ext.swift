//
//  UIVCExtension.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String = APP_NAME, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let oKAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alertController.addAction(oKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlertWithAction(
        title: String = APP_NAME,
        message: String,
        completion: @escaping(_ isCompleted: Bool)->()
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default) { (OkAction) in
            completion(true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlertDualAction(
        title: String = APP_NAME,
        message: String,
        completion: @escaping(_ isCompleted: Bool)->()
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(
        title: "Yes",
        style: .default
        ) { (OkAction) in
            completion(true)
        }
        let noAction = UIAlertAction(
            title: "No",
            style: .destructive,
            handler: nil
        )
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showToast(message : String) {
        DispatchQueue.main.async {
            let toastLabel = UILabel(frame: CGRect(x: (SCREEN_WIDTH - SCREEN_WIDTH * 0.9)/2 , y: 60, width: SCREEN_WIDTH * 0.9, height: 30 ))
            toastLabel.backgroundColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 0.7)
            toastLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 8.0, delay: 0.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
    func showSpinner(onView : UIView, identifier: String = "Default", title: String = "Loading...") {
        let spinnerView = UIView.init(
            frame: onView.bounds
        )
        if identifier == "Default" {
            spinnerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
        }
        
        var activityIndicator = UIActivityIndicatorView()
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        let lableY     = activityIndicator.frame.origin.y +                                       activityIndicator.frame.size.height
        let lableWidth = spinnerView.frame.width
        let label = UILabel(
            frame: CGRect(
                x       : 0.0       ,
                y      : lableY    ,
                width  : lableWidth,
                height : 40
            )
        )
        label.textColor     = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.text          = title
        label.textAlignment = .center
        label.font          = UIFont(name: "Avenir Next Bold", size: 14.0)
        DispatchQueue.main.async {
            spinnerView.addSubview(label)
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        spinnerView.accessibilityIdentifier = identifier
        SPINNERS.append(spinnerView)
    }
    func removeSpinner(identifier: String = "Default") {
        DispatchQueue.main.async {
            for (index, spinner) in SPINNERS.enumerated() {
                if spinner.accessibilityIdentifier == identifier {
                    spinner.removeFromSuperview()
                    if SPINNERS.indices.contains(index){
                        SPINNERS.remove(at: index)
                    }
                }
            }
        }
    }
}
