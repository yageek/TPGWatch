//
//  ParsedDisruption.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// An API Object representing the disruption.
public struct ParsedDisruption: JSONMarshable {

    public let code: String
    public let timestamp: Date
    public let place: String
    public let nature: String
    public let consequence: String
    public let stopName: String

    public init?(json: [String:Any]) {

        guard
                let disruptionCode = json["disruptionCode"] as? String,
                let date = json["timestamp"] as? String,
                let natureValue = json["nature"] as? String,
                let consequenceValue = json["consequence"] as? String,
                let placeValue = json["place"] as? String,
                let name = json["stopName"] as? String else { return nil }

        guard let timestampValue = API.TimestampFormatter.date(from: date) else { return nil }

        code = disruptionCode
        timestamp = timestampValue
        place = placeValue
        nature = natureValue
        consequence = consequenceValue
        stopName = name

    }

}
