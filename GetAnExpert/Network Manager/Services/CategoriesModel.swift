//
//  CategoriesModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 21/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CategoriesModel: Codable {
    let id    : String
    let name  : String
    let image : String
    
    init(json: JSON) {
        id    = json["_id"].stringValue
        name  = json["category"].stringValue
        image = json["image"].stringValue
    }
    
    init() {
        id    = ""
        name  = ""
        image = ""
    }
}
