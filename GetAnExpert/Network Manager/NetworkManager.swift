//
//  NetworkManager.swift
//  DialIn
//
//  Created by M Farhan on 3/25/20.
//  Copyright © 2020 DialIn. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    /* MARK:- API Requests */
    
    ///GET
    func sendGetRequest(
        endPoint   : String,
        completion : @escaping (DataResponse<String>) -> Void
    ) -> Void {
        
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method: .get
        ).responseString { response in
            
            completion(response)
            
        }
        
    }
    
    func sendGetRequestWithHeader(
        endPoint   : String,
        completion : @escaping (DataResponse<String>) -> Void
    ) -> Void {
        
        let headers = Constants.sharedInstance.httpHeaders
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method   : .get,
            encoding : URLEncoding.default,
            headers  : headers
        )
        .responseString(completionHandler: completion)

    }
    
    ///POST
    
    ///Default Encoding
    func sendPostRequest(
        endPoint    : String,
        parameters  : Parameters,
        completion  : @escaping (DataResponse<String>) -> Void
    ){
        Helper.debugLogs(
            any: Constants.sharedInstance.httpHeaders,
            and: "HTTP HEADERS"
        )
        Helper.debugLogs(
            any: parameters,
            and: "Parameters"
        )
        
        let headers = Constants.sharedInstance.httpHeaders
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method      : .post,
            parameters  : parameters,
            encoding    : URLEncoding.default,
            headers     : headers
        ).responseString { (response) in
            completion(response)
        }
        
    }
    
    ///JSON Encoding
    func sendPostRequestWithJSONEncoding(
        endPoint    : String,
        parameters  : Parameters,
        completion  : @escaping (DataResponse<String>) -> Void
    ){
        Helper.debugLogs(
            any: Constants.sharedInstance.httpHeaders,
            and: "HTTP HEADERS"
        )
        Helper.debugLogs(
            any: parameters,
            and: "Parameters"
        )
        
        let headers = Constants.sharedInstance.httpHeaders
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method      : .post,
            parameters  : parameters,
            encoding    : JSONEncoding.default,
            headers     : headers
        ).responseString { (response) in
            completion(response)
        }
        
    }
    
    ///PUT
    func sendPutRequest(
        endPoint    : String,
        parameters  : Parameters,
        completion  : @escaping (DataResponse<String>) -> Void
    ){
        Helper.debugLogs(
            any: Constants.sharedInstance.httpHeaders,
            and: "HTTP HEADERS"
        )
        Helper.debugLogs(
            any: parameters,
            and: "Parameters"
        )
        let headers = Constants.sharedInstance.httpHeaders
        Alamofire.request(
            SERVER_ENV[ENV]! + endPoint,
            method      : .put,
            parameters  : parameters,
            encoding    : URLEncoding.default,
            headers     : headers
        ).responseString { (response) in
            completion(response)
        }
        
    }
    
    ///UPLOAD
    func sendProfileUploadRequest(
        endPoint   : String,
        image      : UIImage,
        parameters : [String:String],
        completion : @escaping (DataResponse<String>) -> Void
    ){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                multipartFormData.append(
                    imageData,
                    withName: "image",
                    fileName: "image.jpg",
                    mimeType: "image/jpg")
            }
            
            for (key, value) in parameters {
                multipartFormData.append(
                    value.data(using: String.Encoding.utf8)!,
                    withName: key
                )
            }
            
        }, to      : SERVER_ENV[ENV]! + endPoint,
           method  : .put,
           headers : Constants.sharedInstance.httpHeaders
        ) { (result) in

            switch result {
                
            case .success(request: let request, streamingFromDisk:_, streamFileURL:_):
                
                request.uploadProgress { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                }
                request.responseString(completionHandler: completion)
                
            case .failure(_):
                break
            }
        }
        
    }
    
    func sendSingleImageUploadRequest(
        endPoint   : String           ,
        image      : UIImage          ,
        imageKey   : String           ,
        parameters : [String: String] ,
        completion : @escaping (DataResponse<String>) -> Void
    ){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                multipartFormData.append(
                    imageData,
                    withName: imageKey,
                    fileName: "image.jpg",
                    mimeType: "image/jpg")
            }
            
            for (key, value) in parameters {
                multipartFormData.append(
                    value.data(using: String.Encoding.utf8)!,
                    withName: key
                )
            }
            
        }, to      : SERVER_ENV[ENV]! + endPoint,
           method  : .post,
           headers : Constants.sharedInstance.httpHeaders
        ) { (result) in

            switch result {
                
            case .success(request: let request, streamingFromDisk:_, streamFileURL:_):
                
                request.uploadProgress { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                }
                request.responseString(completionHandler: completion)
                
            case .failure(_):
                break
            }
        }
        
    }
    
}
