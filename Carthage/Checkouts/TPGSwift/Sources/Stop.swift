//
//  ParsedStopsRecord.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// A Stop response
public struct Stop: Decodable, APIObject {

    public static var recordName = "stops"

    public enum CodingKeys: String, CodingKey {
        case name = "stopName"
        case code = "stopCode"
        case connections
        case distance
    }

    /// The name of the stop
    public let name: String

    /// The code of the stops
    public let code: String

    /// The connection of the stops
    public let connections: [Connection]
    
    /// The distance to the provided
    /// latitude and longitude
    public let distance: Double?
}
