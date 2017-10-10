//
//  ParsedPhysicalStopRecord.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// ParsedPhysicalStopRecord represents a set of physical stops.
public struct ParsedPhysicalStopRecord: JSONMarshable {

    public struct ParsePhysicalStopInfos: JSONMarshable {
        public let name: String
        public let code: String
        public let stops: [ParsedPhysicalStop]

        public init?(json: [String:Any]) {

            guard
                    let stopCode = json["stopCode"] as? String,
                    let stopName = json["stopName"] as? String,
                    let stopsArray = json["stops"] as? [[String:Any]] else { return nil }

            name = stopName
            code = stopCode
            stops = stopsArray.flatMap { ParsedPhysicalStop(json: $0) }
        }
    }

    public struct ParsedPhysicalStop: JSONMarshable {

        public let code: String
        public let name: String

        public let connections: [ParsedConnection]
        public let coordinates: ParsedCoordinates

        public init?(json: [String:Any]) {

            guard
                    let physicalStopCode = json["physicalStopCode"] as? String,
                    let stopName = json["stopName"] as? String,
                    let coordsRaw = json["coordinates"] as? [String: AnyObject],
                    let connectsRaw = json["connections"] as? [[String:Any]] else { return nil }


            guard let coords = ParsedCoordinates(json: coordsRaw) else { return nil }

            code = physicalStopCode
            name = stopName
            coordinates = coords
            connections = connectsRaw.flatMap { ParsedConnection(json: $0) }
        }
    }


    public let timestamp: Date
    public let stops: [ParsePhysicalStopInfos]

    public init?(json: [String:Any]) {

        guard let timestampValue = json["timestamp"] as? String, let stopsArray = json["stops"] as? [[String:Any]] else { return nil }

        guard let date = API.TimestampFormatter.date(from: timestampValue) else { return nil }

        timestamp = date
        stops = stopsArray.flatMap { ParsePhysicalStopInfos(json: $0) }

    }

}
