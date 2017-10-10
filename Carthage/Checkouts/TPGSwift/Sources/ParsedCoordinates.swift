//
//  ParsedCoordinates.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// An API object representing a coordinate in space.
public struct ParsedCoordinates: JSONMarshable {


    /// The latitude value.
    public let latitude: Double

    /// The longitude value.
    public let longitude: Double

    /// The referential.
    public let referential: String

    public init?(json: [String:Any]) {

        guard
            let lat = json["latitude"] as? Double,
            let long = json["longitude"] as? Double,
            let ref = json["referential"] as? String else { return nil }

        latitude = lat
        longitude = long
        referential = ref
    }
}
