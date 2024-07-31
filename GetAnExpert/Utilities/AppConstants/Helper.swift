//
//  Helper.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Kingfisher

class Helper {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
    
    static func debugLogs(any data: Any, and title: String = "Log") {
        print("============= DEBUG LOGS START =================")
        print("\(title): \(data)")
        print("=============  DEBUG LOGS END  =================")
        print("\n \n")
    }
    
    static func errorWithDescription(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : description]
        return NSError(domain: "app", code: code, userInfo: userInfo)
    }
    
    static func setShadow(layer: CALayer,shadowRadius: CGFloat,shadowOpacity: Float, shadowColor: CGColor, shadowOffset: CGSize) {
        layer.shadowColor    = shadowColor
        layer.shadowRadius   = shadowRadius
        layer.shadowOpacity  = shadowOpacity
        layer.shadowOffset   = shadowOffset
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    ///Double Precision
    static func precise(doubleValue value: Double, ByUnits units: Int) -> Double  {
        let doubleUnits = Double(units)
        return Double(round(doubleUnits * value)/doubleUnits)
    }
    
    static func setInitialViewController( window : UIWindow){
        if Constants.sharedInstance.isAlreadyLaunch {
            let navController = MAIN_STORYBOARD.instantiateInitialViewController() as! UINavigationController
            if (Constants.sharedInstance.USER != nil) {
                if Constants.sharedInstance.USER!.isVerfifed != "" {
                    if Constants.sharedInstance.USER!.isProvider {
                        let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.PROVIDER_HOME_VC)
                        let loginVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.LOGIN_VC) as! LoginVC
                        navController.viewControllers = [loginVC,homeVC]
                    } else {
                        let homeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.HOME_VC)
                        let loginVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.LOGIN_VC) as! LoginVC
                        navController.viewControllers = [loginVC,homeVC]
                    }
                } else {
                    let loginVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.LOGIN_VC) as! LoginVC
                    let verifiedVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.VALIDATION_VC) as! ValidationVC
                    navController.viewControllers = [loginVC,verifiedVC]
                }
            } else {
                let loginVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.ViewControllers.LOGIN_VC) as! LoginVC
                navController.viewControllers = [loginVC]
            }
            window.rootViewController    = navController
        } else {
            Constants.sharedInstance.isAlreadyLaunch = true
        }
    }
    
    static func setImage(isUser : Bool, imageView : UIImageView, imageUrl: String) {
        var placeholder = UIImage()
        if isUser {
            placeholder = PLACEHOLDER_USER!
        } else {
            placeholder = PLACEHOLDER_IMAGE!
        }
        let stringURL = imageUrl.replacingOccurrences(of: " ", with: "%20")
        if let url = URL(string: IMAGES_ENV[ENV]! + stringURL) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: placeholder)
        }
    }
    
    static func getSubviewsOf<T : UIView>(view:UIView) -> [T] {
        var subviews = [T]()
        for subview in view.subviews {
            subviews += getSubviewsOf(view: subview) as [T]
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }
}
