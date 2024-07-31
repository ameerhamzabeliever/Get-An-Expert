//
//  PackagesModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 24/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PackagesModel: Codable {
    let id          : String
    let name        : String
    let price       : String
    let description : String
    let image       : String
    
    init(json: JSON) {
        id          = json["_id"].stringValue
        name        = json["name"].stringValue
        price       = json["price"].stringValue
        description = json["description"].stringValue
        image       = json["image"].stringValue
    }
}

struct FeaturedServices {
    let id          : String
    let name        : String
    let price       : String
    let description : String
    let image       : String
    let isFavourite : Bool
    let favourites  : [String]
    let user        : UserModel
    let rating      : Double
    
    init(json: JSON) {
        id          = json["_id"].stringValue
        name        = json["name"].stringValue
        price       = json["price"].stringValue
        description = json["description"].stringValue
        image       = json["image"].stringValue
        user        = UserModel(json: json["user"])
        rating      = json["rating"].doubleValue
        favourites  = json["favourites"].arrayValue.map({ $0.stringValue })
        
        if favourites.count > 0 {
            isFavourite = true
        } else {
            isFavourite = false
        }
        
    }
}
