//
//  Experts.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 24/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation

import Alamofire
import Foundation

extension NetworkManager {
    func getFeaturedExperts(
        pageNumber : String,
        language   : String,
        location   : String,
        completion : @escaping (DataResponse<String>
    ) -> ()) {
        sendGetRequest(
            endPoint    : "experts/all?page=\(pageNumber)&lan=\(language)&address=\(location)",
            completion  : completion
        )
    }
    func getAllServices(
        pageNumber : String,
        language   : String,
        location   : String,
        completion : @escaping (DataResponse<String>
    ) -> ()) {
        sendGetRequestWithHeader(
            endPoint: "services/all?page=\(pageNumber)&lan=\(language)&address=\(location)",
            completion: completion
        )
    }
}
