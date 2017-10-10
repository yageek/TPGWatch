//
//  ParsedLineColorRecord.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// ParsedLineColorRecord represents a set of `ParsedLineColor` objects.
public struct ParsedLineColorRecord: JSONMarshable {

    public let timestamp: Date

    public let lineColors: [ParsedLineColor]

    public init?(json: [String:Any]) {

        guard let timestamp = json["timestamp"] as? String, let colors = json["colors"] as? [[String:Any]] else { return nil }

        self.timestamp = API.TimestampFormatter.date(from: timestamp)!

        var newColors: [ParsedLineColor] = []

        for jsonColor in colors {
            if let color = ParsedLineColor(json: jsonColor) {
                newColors.append(color)
            }
        }

        self.lineColors = newColors
    }

}

/// ParsedLineColor represents an API line color object.
public struct ParsedLineColor {

    public let hexa: String
    public let lineCode: String
    public let background: String
    public let text: String

    init?(json: [String:Any]) {

        guard
            let color = json["hexa"] as? String,
            let lineCode = json["lineCode"] as? String,
            let background = json["background"] as? String,
            let text = json["text"] as? String else {
            return nil
        }

        self.hexa = color
        self.lineCode = lineCode
        self.background = background
        self.text = text
    }

}
