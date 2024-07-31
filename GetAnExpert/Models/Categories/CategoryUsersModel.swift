//
//  UserCategoriesModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 21/09/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CategoryUsersModel {
    let id    : String
    let name  : String
    let image : String
    let users : [UserModel]
    
    init(json: JSON) {
        id    = json["_id"].stringValue
        name  = json["category"].stringValue
        image = json["image"].stringValue
        users = json["users"].arrayValue.map({UserModel(json: $0)})
    }
}

//struct CategoryUser {
//    let id       : String
//    let name     : String
//    let category : CategoriesModel
//    let language : LanguagesModel
//    let address  : Address
//
//    init(json: JSON) {
//        id        = json["_id"].stringValue
//        name      = json["name"].stringValue
//        category  = CategoriesModel(json: json["category"])
//        language  = LanguagesModel(json: json["language"])
//        address   = Address(json: json["address"])
//    }
//}
