//
//  SlotsModel.swift
//  GetAnExpert
//
//  Created by Umar Farooq on 04/10/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SlotsModel {
    let day   : WeekDays
    var slots : [TimeSlots]
    
    init(day: WeekDays, slots: [TimeSlots]) {
        self.day   = day
        self.slots = slots
    }
}

struct TimeSlots {
    var from       : String
    var fromIndex  : Int
    var fromId     : String
    var to         : String
    var toIndex    : Int
    var toId       : String
    var identifier : String
    
    init(json: JSON) {
        from       = json["from"]["slot"].stringValue
        to         = json["to"]["slot"].stringValue
        fromIndex  = json["fromIndex"].intValue
        fromId     = json["from"]["_id"].stringValue
        toIndex    = json["toIndex"].intValue
        toId       = json["to"]["_id"].stringValue
        identifier = ""
    }
    
    init(
        from       : String,
        fromIndex  : Int,
        fromId     : String,
        to         : String,
        toIndex    : Int,
        toId       : String,
        identifier : String
    ) {
        self.from       = from
        self.fromIndex  = fromIndex
        self.fromId     = fromId
        self.to         = to
        self.toIndex    = toIndex
        self.toId       = toId
        self.identifier = identifier
    }
    
    init(identifier: String) {
        from            = ""
        fromIndex       = 0
        fromId          = ""
        to              = ""
        toIndex         = 0
        toId            = ""
        self.identifier = identifier
    }
}


struct WeekModel {
    let day   : WeekDays
    var slots : [Slots]
    
    init(day: WeekDays, slots: [Slots]) {
        self.day   = day
        self.slots = slots
    }
}

struct Slots {
    let id   : String
    let slot : String
    
    init(json: JSON) {
        id   = json["_id"].stringValue
        slot = json["slot"].stringValue
    }
}
