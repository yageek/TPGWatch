//
//  ParsedStopsRecord.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// ParsedStopsRecord represents a set of `ParsedStop`.
public struct ParsedStopsRecord: JSONMarshable {

    /// ParsedStop represents an API object for stop.
    public struct ParsedStop {

        public let name: String
        public let code: String
        public let connections: [ParsedConnection]
        public let distance: Double?

        public init?(json: [String:Any]) {

            guard let stopCode = json["stopCode"] as? String, let stopName = json["stopName"] as? String else { return nil }
            name = stopName
            code = stopCode

            guard let connections = json["connections"] as? [[String:Any]] else { return nil }

            var connectionsArray: [ParsedConnection] = []
            for jsonConnection in connections {
                if let  connection = ParsedConnection(json: jsonConnection) {
                    connectionsArray.append(connection)
                }

            }

            self.connections = connectionsArray

            if let dist = json["distance"] as? Double {
                distance = dist
            } else {
                distance = nil
            }
        }
    }

    public let timestamp: Date
    public let stops: [ParsedStop]

    public init?(json: [String:Any]) {

        guard let timestampValue = json["timestamp"] as? String, let stopsArray = json["stops"] as? [[String:Any]] else { return nil }

        guard let date = API.TimestampFormatter.date(from: timestampValue) else { return nil }

        timestamp = date
        stops = stopsArray.flatMap { ParsedStop(json: $0) }

    }

}
