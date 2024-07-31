//
//  AppointmentsModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 07/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AppointmentsModel {
    let id      : String
    let status  : String
    let date    : String
    let toTimeSlot: String
    let fromtimeSlot: String
    let city: String
    let street: String
    let country: String
    let user    : UserModel
    let service : PackagesModel
    let provider: ProviderModel
    
    init(json: JSON) {
        id           = json["_id"].stringValue
        status       = json["status"].stringValue
        date         = json["date"].stringValue
        toTimeSlot   = json["toTime"]["slot"].stringValue
        fromtimeSlot = json["fromTime"]["slot"].stringValue
        city         = json["provider"]["address"]["city"].stringValue
        street       = json["provider"]["address"]["street"].stringValue
        country      = json["provider"]["address"]["country"].stringValue
        user         = UserModel(json: json["user"])
        provider     = ProviderModel(json: json["provider"])
        service      = PackagesModel(json: json["package"])
    }
}
