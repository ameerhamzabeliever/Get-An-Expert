//
//  ProviderModel.swift
//  GetAnExpert
//
//  Created by Office on 17/12/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import SwiftyJSON

struct ProviderModel: Codable{
    let name : String
    let id   : String
    
    init(json: JSON) {
        name = json["name"].stringValue
        id   = json["_id"].stringValue
    }
}
