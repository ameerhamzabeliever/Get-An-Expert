//
//  Twilio.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 21/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Alamofire
import Foundation

extension NetworkManager {
    
    func getChatToken(
        parameters: [String: Any],
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : Constants.endPoints.CHAT_TOKEN,
            parameters : parameters,
            completion : completion
        )
    }
    func getVideoCallToken(
        partnerId : String,
        completion: @escaping (DataResponse<String>) -> ()
    ) {
        sendPostRequest(
            endPoint   : "video/\(partnerId)/token",
            parameters : [:],
            completion : completion
        )
    }
}
