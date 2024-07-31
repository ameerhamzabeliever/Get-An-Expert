//
//  Constants.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import Alamofire

struct Constants {
    /* MARK:- Singleton struct initilization */
    static var sharedInstance : Constants = Constants()
    
    var isGuestUser : Bool = false
    
    var USER: UserModel? {
        get {
            if let user = DEFAULTS.object(
                forKey: Constants.userDefaults.USER
                ) as? Data {
                
                let decoder = JSONDecoder()
                return try! decoder.decode(
                    UserModel.self, from: user
                )
            }
            return nil
        } set {
            if let user = newValue {
                let encoder    = JSONEncoder()
                if let encoded = try? encoder.encode(user) {
                    DEFAULTS.set(encoded, forKey: Constants.userDefaults.USER)
                }
            } else {
                DEFAULTS.set(nil, forKey: Constants.userDefaults.USER)
            }
        }
    }
    var fcmToken : String {
        get {
            return UserDefaults.standard.string(forKey: Constants.userDefaults.FCM_TOKEN) ?? ""
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.FCM_TOKEN)
        }
    }
    var httpHeaders : HTTPHeaders {
        get {
            return [
                "Authorization" : UserDefaults.standard.string(forKey: Constants.userDefaults.HTTP_HEADERS) ?? ""
            ]
        }
    }
    var Email : String {
        get {
            return UserDefaults.standard.string(forKey: Constants.userDefaults.EMAIL) ?? ""
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.EMAIL)
        }
    }
    var Password : String {
        get {
            return UserDefaults.standard.string(forKey: Constants.userDefaults.PASSWORD) ?? ""
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.PASSWORD)
        }
    }
    var isAlreadyLaunch : Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.userDefaults.ALREADY_LAUNCH)
        } set {
            DEFAULTS.set(newValue, forKey: Constants.userDefaults.ALREADY_LAUNCH)
        }
    }
    /* MARK:- End Points */
    struct endPoints {
        static let SIGN_UP                 = "register"
        static let LOGIN                   = "login"
        static let GOOGLE_LOGIN            = "auth/google"
        static let FACEBOOK_LOGIN          = "auth/facebook"
        static let LINKED_IN_LOGIN         = "auth/linkedin"
        static let RESET_PASSWORD          = "password-reset"
        static let VERIFY                  = "verify-email"
        static let RESEND_EMAIL            = "resend-verification-email"
        static let UPDATE_ADDRESS          = "profile/update/address"
        static let GET_PROFILE             = "profile?profile=full"
        static let UPDATE_CUSTOMER_PROFILE = "profile/update/customer"
        static let UPDATE_PROVIDER_PROFILE = "profile/update/service-provider"
                
        static let GET_ALL_LANGUAGES       = "languages"
        static let GET_ALL_CATEGORIES      = "categories"
        
        static let GET_MY_FAVOURITES       = "favourites/services"
        
        static let CREATE_PACKAGES         = "service/create"
        static let GET_MY_PACKAGES         = "service/my"
        
        static let GET_ALL_SLOTS           = "slots/all"
        static let CREATE_SLOTS            = "slots/create"
        static let GET_USER_SLOTS          = "user/slots"
        
        static let BOOK_APPOINTMENT          = "book/slots"
        static let GET_MY_APPOINTMENTS       = "user/appointments"
        static let GET_PROVIDER_APPOINTMENTS = "provider/appointments"
        static let UPDATE_APPOINTMENT        = "update/appointment"
        
        static let CHAT_TOKEN = "chat/token"
    }
    /* MARK:- View Controllers */
    struct ViewControllers {
        static let LOGIN_VC           = "LoginVC"
        static let REGISTER_VC        = "RegisterVC"
        static let VALIDATION_VC      = "ValidationVC"
        static let ONBOARDING_VC      = "OnboardingVC"
        static let FORGET_VC          = "ForgetVC"
        static let HOME_VC            = "HomeVC"
        static let PROVIDER_HOME_VC   = "ProviderHomeVC"
        static let USER_INFO_VC       = "UserInfoVC"
        static let PROVIDER_INFO_VC   = "ProviderInfoVC"
        static let ADDRESS_VC         = "AddressVC"
        static let ALL_CATEGORIES_VC  = "AllExpertCategoriesVC"
        static let ALL_EXPERTS_VC     = "AllExpertsVC"
        static let ALL_SERVICES_VC    = "AllServicesVC"
        static let PROVIDER_DETAIL_VC = "ProviderDetailVC"
        static let PACKAGES_VC        = "PackagesVC"
        static let ADD_PACKAGE_VC     = "AddPackageVC"
        static let ADD_PAYMENT_VC     = "AddPaymentVC"
        static let NEW_CARD_VC        = "NewCardVC"
        static let REVIEW_VC          = "ReviewVC"
        static let CREATE_SLOTS_VC    = "CreateSlotsVC"
        static let SELECT_SLOTS_VC    = "SelectSlotsVC"
        static let APPOINTMENT_DETAIL_VC = "AppointmentDetailsVC"
        static let SEARCH_RESULTS_VC  = "SearchResultsVC"
        
        static let CHAT_VC            = "TwilioChatVC"
        static let VIDEO_CALL_VC      = "VideoCallVC"
        static let VOICE_CALL_VC      = "VoiceCallVC"
    }
    
    /* MARK:- Collection View Cells */
    struct CVCells {
        static let ONBOARDING_CELL = "OnboardingCell"
        static let EXPERTS_CELL    = "ExpertsCell"
        static let CATEGORY_CELL   = "CategoryCell"
        static let SERVICE_CELL    = "ServiceCell"
    }
    
    /* MARK:- Table View Cells */
    struct TVCells {
        static let APPOINTMENT_CELL   = "AppointmentCell"
        static let REJECTED_CELL      = "RejectedCell"
        static let PACKAGE_CELL       = "PackageCell"
        static let REVIEW_CELL        = "ReviewCell"
        static let NOTIFICATIONS_CELL = "NotificationCell"
        static let CARD_CELL          = "CardCell"
        
        static let LEFT_CHAT_CELL     = "LeftChatCell"
        static let RIGHT_CHAT_CELL    = "RightChatCell"
    }
    
    /* MARK:- User Defaults */
    struct userDefaults {
        static let USER            = "user"
        static let HTTP_HEADERS    = "httpHeaders"
        static let EMAIL           = "Email"
        static let PASSWORD        = "Password"
        static let ALREADY_LAUNCH  = "AlreadyLaunch"
        static let FCM_TOKEN       = "fcmToken"
    }
}
