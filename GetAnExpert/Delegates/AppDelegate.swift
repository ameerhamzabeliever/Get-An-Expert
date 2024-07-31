//
//  AppDelegate.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 25/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import Braintree
import DropDown
import Firebase
import GooglePlaces
import GoogleSignIn
import FBSDKLoginKit
import LinkedinSwift
import UserNotifications
import FirebaseMessaging
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        /// Configure Firebase
        FirebaseApp.configure()
        /// APN Setup
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            let center      = UNUserNotificationCenter.current()
            center.delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            center.requestAuthorization(
                options           : authOptions,
                completionHandler : {_, _ in }
            )
        } else {
          let settings : UIUserNotificationSettings = UIUserNotificationSettings(
            types      : [.alert, .badge, .sound],
            categories : nil
          )
          application.registerUserNotificationSettings(settings)
        }
        
        Messaging.messaging().delegate = self

        application.registerForRemoteNotifications()
        /// Setup IQ Keyboard Manager
        IQKeyboardManager.shared.enable = true
        /// Google Place API's autocomplete UI control
        GMSPlacesClient.provideAPIKey("AIzaSyAWJT-MNjP_WOSmmiponjy6bppH1L1-3Pg")
        /// FOR DROPDOWN
        DropDown.startListeningToKeyboard()
        /// Setting Initial View Controller
        if let window = window {
            Helper.setInitialViewController(window: window)
        }
        /// PayPal Integeration
        BTAppSwitch.setReturnURLScheme("com.saifurrahman.getanexpert.payments")
        return true
    }
    
    func application(
        _ app       : UIApplication,
        open url    : URL,
        options     : [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        /// For LinkenIn
        if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(app, open: url, sourceApplication: nil, annotation: nil)
        }
        /// For PayPal
        if url.scheme?.localizedCaseInsensitiveCompare("com.saifurrahman.getanexpert.payments") == .orderedSame {
             return BTAppSwitch.handleOpen(url, options: options)
         }
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
}

/* MARK:-  Apple Push Notifications */

/// UN User Notification Center Delegate
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let _ = notification.request.content
        if #available(iOS 14, *) {
            completionHandler([.list, .banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}

/// Messaging Delegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Constants.sharedInstance.fcmToken = fcmToken!
        Helper.debugLogs(any: Constants.sharedInstance.fcmToken, and: "FCM Token")
    }
}
