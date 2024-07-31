//
//  UserServices.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/08/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//
import Alamofire
import Foundation

extension NetworkManager {
    
    func signUp(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.SIGN_UP,
            parameters : param,
            completion : completion
        )
    }
    func login(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.LOGIN,
            parameters : param,
            completion : completion
        )
    }
    func googleLogin(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.GOOGLE_LOGIN,
            parameters : param,
            completion : completion
        )
    }
    func facebookLogin(
         param       : [String:Any],
         completion  : @escaping (DataResponse<String>) -> ()
     ) {
         sendPostRequest(
             endPoint   : Constants.endPoints.FACEBOOK_LOGIN,
             parameters : param,
             completion : completion
         )
     }
    func verifyEmail(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.VERIFY,
            parameters : param,
            completion : completion
        )
    }
    func resetPassword(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.RESET_PASSWORD,
            parameters : param,
            completion : completion
        )
    }
    func resendEmail(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.RESEND_EMAIL,
            parameters : [:],
            completion : completion
        )
    }
    func getProfile(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint    : Constants.endPoints.GET_PROFILE,
            completion  : completion)
    }
    func updateProfile(
        param       : [String : String],
        image       : UIImage?,
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        if image != nil {
            sendProfileUploadRequest(
                endPoint    : Constants.endPoints.UPDATE_CUSTOMER_PROFILE,
                image       : image!,
                parameters  : param,
                completion  : completion
            )
        } else {
            sendPutRequest(
                endPoint    : Constants.endPoints.UPDATE_CUSTOMER_PROFILE,
                parameters  : param,
                completion  : completion
            )
        }
    }
    func updateProfileProvider(
        param       : [String : String],
        image       : UIImage?,
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        if image != nil {
            sendProfileUploadRequest(
                endPoint    : Constants.endPoints.UPDATE_PROVIDER_PROFILE,
                image       : image!,
                parameters  : param,
                completion  : completion
            )
        } else {
            sendPutRequest(
                endPoint    : Constants.endPoints.UPDATE_PROVIDER_PROFILE,
                parameters  : param,
                completion  : completion
            )
        }
    }
    func updateAddress(
        param       : [String:Any],
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendPutRequest(
            endPoint   : Constants.endPoints.UPDATE_ADDRESS,
            parameters : param,
            completion : completion
        )
    }
    func getOtherUserProfile(
        otherUserId : String,
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint  : "profile/\(otherUserId)",
            completion: completion
        )
    }
    func getOtherUserRatings(
        otherUserId : String,
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint  : "rating/\(otherUserId)/user",
            completion: completion
        )
    }
}
