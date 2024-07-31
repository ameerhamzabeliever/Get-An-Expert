//
//  LanguagesModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 21/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LanguagesModel: Codable {
    let id   : String
    let name : String
    
    init(json: JSON) {
        id   = json["_id"].stringValue
        name = json["language"].stringValue
    }
    
    init() {
        id   = ""
        name = ""
    }
}
