//
//  RatingModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 14/11/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct RatingModel {
    let content : String
    let stars   : Double
    let user    : RatingUser
    
    init(json: JSON) {
        self.content = json["content"].stringValue
        self.stars   = json["stars"].doubleValue
        self.user    = RatingUser(json: json["user"])
    }
    
    init() {
        self.content = ""
        self.stars   = 0.0
        self.user    = RatingUser()
    }
}

struct RatingUser {
    let name    : String
    let profile : RatingUserProfile
    
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.profile = RatingUserProfile(json: json["profile"])
    }
    
    init() {
        self.name = ""
        self.profile = RatingUserProfile()
    }
}

struct RatingUserProfile {
    let image: String
    
    init(json: JSON) {
        self.image = json["image"].stringValue
    }
    
    init() {
        self.image = ""
    }
}
