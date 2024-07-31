//
//  UserModel.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 12/08/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import SwiftyJSON

struct UserModel: Codable {
    
    let id           : String
    let name         : String
    let email        : String
    let phone        : String
    let code         : String
    let providerInfo : ServiceProvider
    let isProvider   : Bool
    let address      : Address
    let services     : [PackagesModel]
    let gender       : String
    let dob          : String
    let image        : String
    let isVerfifed   : String
    let language     : LanguagesModel
    let category     : CategoriesModel
    let isSocial     : Bool
    let rating       : Double
    
    init(json: JSON) {
        id           = json["_id"]               .stringValue
        name         = json["name"]              .stringValue
        email        = json["email"]             .stringValue
        phone        = json["phoneNumber"]       .stringValue
        code         = json["phoneCode"]         .stringValue
        language     = LanguagesModel(json: json["language"])
        category     = CategoriesModel(json: json["category"])
        services     = json["services"].arrayValue.map({PackagesModel(json: $0)})
        gender       = json["profile"]["gender"] .stringValue
        dob          = json["profile"]["dob"]    .stringValue
        image        = json["profile"]["image"]  .stringValue
        isVerfifed   = json["emailVerifiedAt"]   .stringValue
        address      = Address(json: json["address"])
        if json["serviceProvider"].isEmpty {
            isProvider   = false
            providerInfo = ServiceProvider(json: json["serviceProvider"])
        } else {
            isProvider   = true
            providerInfo = ServiceProvider(json: json["serviceProvider"])
        }
        if json["providerId"] == "" {
            isSocial = false
        } else {
            isSocial = true
        }
        
        rating = json["rating"].doubleValue
    }
    
    init() {
        id           = ""
        name         = ""
        email        = ""
        phone        = ""
        code         = ""
        services     = []
        language     = LanguagesModel()
        category     = CategoriesModel()
        gender       = ""
        dob          = ""
        image        = ""
        isVerfifed   = ""
        isProvider   = false
        address      = Address()
        providerInfo = ServiceProvider()
        isSocial     = false
        rating       = 0.0
    }
}

struct ServiceProvider : Codable {
    
    let degree         : String
    let about          : String
    let specializrtion : String
    let facebook       : String
    let linkedIn       : String
    let twitter        : String
    
    init(json: JSON) {
        degree         = json["degree"]         .stringValue
        about          = json["about"]          .stringValue
        specializrtion = json["specialization"] .stringValue
        facebook       = json["facebook"]       .stringValue
        linkedIn       = json["linkedin"]       .stringValue
        twitter        = json["twitter"]        .stringValue
    }
    
    init() {
        degree          = ""
        about           = ""
        specializrtion  = ""
        facebook        = ""
        linkedIn        = ""
        twitter         = ""
    }
}

struct Address : Codable {
    let country     : String
    let city        : String
    let postalCode  : String
    let street      : String
    let fullAddress : String
    
    init(json : JSON) {
        country     = json["country"]     .stringValue
        city        = json["city"]        .stringValue
        postalCode  = json["postalCode"]  .stringValue
        street      = json["street"]      .stringValue
        fullAddress = json["fullAddress"] .stringValue
    }
    
    init() {
        country     = ""
        city        = ""
        postalCode  = ""
        street      = ""
        fullAddress = ""
    }
}
