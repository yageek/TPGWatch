//
//  ParsedPhysicalStop.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// A Physical Stop Informations response
public struct PhysicalStopInfos: Decodable, APIObject {
    public static var recordName = "stops"

    /// The name of the stop
    public let name: String

    /// The code of the stop
    public let code: String

    /// The physical stops if refers
    public let stops: [PhysicalStop]

    enum CodingKeys: String, CodingKey {
        case name = "stopName"
        case code = "stopCode"
        case stops = "physicalStops"
    }

    /// A physical stop response
    public struct PhysicalStop: Decodable {

        /// The code of the stop
        public let code: String

        /// The name of the stop
        public let name: String

        /// The connections of the stops
        public let connections: [Connection]

        /// The coordinates of the stop
        public let coordinates: Coordinates

        enum CodingKeys: String, CodingKey {
            case name = "stopName"
            case code = "physicalStopCode"

            case connections
            case coordinates
        }
    }
}
