//
//  Global.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 27/06/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.

import UIKit

/* MARK:- Constants */
var SPINNERS          : [UIView] = []
let PLACEHOLDER_IMAGE = UIImage(named: "placeholder")
let PLACEHOLDER_USER  = UIImage(named: "user-Placeholder")
let APP_NAME          = "GetAnExpert"
let SCREEN_WIDTH      = UIScreen.main.bounds.width
let SCREEN_HEIGHT     = UIScreen.main.bounds.height
let DEFAULTS          = UserDefaults.standard

let PAYPAL_TOKENIZATION = "sandbox_4xg5t5mp_cx6s4995c7k73jpv"

/* MARK:- Storyboards */
let MAIN_STORYBOARD : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

/* MARK:- Enums */
enum WeekDays: String, CaseIterable {
    case monday    = "monday"
    case tuesday   = "tuesday"
    case wednesday = "wednesday"
    case thursday  = "thursday"
    case friday    = "friday"
    case saturday  = "saturday"
}

/* MARK:- Application ENV */
let ENV = "production"

let SERVER_ENV = [
    "staging"     : "http://192.168.10.6:5000/api/",
    "production"  : "https://get-an-expert.codesbinary.website/api/"
]

let IMAGES_ENV = [
    "staging"     : "",
    "production"  : ""
]
