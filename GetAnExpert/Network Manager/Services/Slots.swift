//
//  Slots.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 04/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Alamofire
import Foundation

extension NetworkManager {
    func getAllSlots(
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint   : Constants.endPoints.GET_ALL_SLOTS,
            completion : completion
        )
    }
    func createSlots(
        parameters: [String: Any],
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequestWithJSONEncoding(
            endPoint   : Constants.endPoints.CREATE_SLOTS,
            parameters : parameters,
            completion : completion
        )
    }
    func getMySlots(
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendGetRequestWithHeader(
            endPoint: Constants.endPoints.GET_USER_SLOTS,
            completion: completion
        )
    }
    func getSlotsByUserId(
        userId    : String,
        completion: @escaping (DataResponse<String>) -> ()
    )  {
        sendGetRequest(
            endPoint  : "user/\(userId)/slots",
            completion: completion
        )
    }
}
