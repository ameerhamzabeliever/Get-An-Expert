//
//  Categories.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 21/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Alamofire
import Foundation

extension NetworkManager {
    
    func getFeaturedCategories(
        pageNumber  : String,
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint  : "categories?page=\(pageNumber)",
            completion: completion
        )
    }
    func getAllCategories(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint  : Constants.endPoints.GET_ALL_CATEGORIES,
            completion: completion
        )
    }
    func getAllLanguages(
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint  : Constants.endPoints.GET_ALL_LANGUAGES,
            completion: completion
        )
    }
    func getCategoryUsers(
        categoryId  : String,
        completion  : @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequest(
            endPoint  : "category/\(categoryId)/users",
            completion: completion
        )
    }
}
