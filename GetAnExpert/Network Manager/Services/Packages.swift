//
//  Packages.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 22/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Alamofire
import Foundation

extension NetworkManager {
    
    func createPackage(
        image       : UIImage          ,
        imageKey    : String           ,
        parameters  : [String: String] ,
        completion  : @escaping (DataResponse<String>
    ) -> ()){
        sendSingleImageUploadRequest(
            endPoint    : Constants.endPoints.CREATE_PACKAGES,
            image       : image,
            imageKey    : imageKey,
            parameters  : parameters,
            completion  : completion
        )
    }
    func getMyPackages(
        completion  : @escaping (DataResponse<String>
    ) -> ()){
        sendGetRequestWithHeader(
            endPoint    : Constants.endPoints.GET_MY_PACKAGES,
            completion  : completion
        )
    }
    func deleteMyPackage(
        packageId  : String,
        completion : @escaping (DataResponse<String>
    ) -> ()) {
        sendPostRequest(
            endPoint   : "service/\(packageId)/delete",
            parameters : [:],
            completion : completion
        )
    }
    func updatePackage(
        packageId   : String           ,
        image       : UIImage          ,
        imageKey    : String           ,
        parameters  : [String: String] ,
        completion  : @escaping (DataResponse<String>
    ) -> ()){
        sendSingleImageUploadRequest(
            endPoint    : "service/\(packageId)/update",
            image       : image,
            imageKey    : imageKey,
            parameters  : parameters,
            completion  : completion
        )
    }
    func favoutirePackage(
        serviceId : String,
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint: "service/\(serviceId)/favourite",
            completion: completion
        )
    }
    func unfavoutirePackage(
        serviceId : String,
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint: "service/\(serviceId)/unfavourite",
            completion: completion
        )
    }
    func getMyFavouritePackages(
        completion: @escaping (DataResponse<String>) -> ()
    ){
        sendGetRequestWithHeader(
            endPoint: Constants.endPoints.GET_MY_FAVOURITES,
            completion: completion
        )
    }
    func bookAppointment(
        parameters: [String: Any],
        completion: @escaping (DataResponse<String>)->()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.BOOK_APPOINTMENT,
            parameters : parameters,
            completion : completion
        )
    }
    func getMyAppointments(
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint  : Constants.endPoints.GET_MY_APPOINTMENTS,
            completion: completion
        )
    }
    func getProviderAppointments(
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint  : Constants.endPoints.GET_PROVIDER_APPOINTMENTS,
            completion: completion
        )
    }
    func sendRatingAndReview(
        serviceId : String,
        parameters: [String: Any],
        completion: @escaping (DataResponse<String>) -> ()
    ){
        sendPostRequest(
            endPoint    : "rating/\(serviceId)",
            parameters  : parameters,
            completion  : completion
        )
    }
    func updateAppointment(
        parameters: [String: Any],
        completion: @escaping (DataResponse<String>)->()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.UPDATE_APPOINTMENT,
            parameters : parameters,
            completion : completion
        )
    }
}
