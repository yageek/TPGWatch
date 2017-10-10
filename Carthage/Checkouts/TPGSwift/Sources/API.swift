//
//  API.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// API is the enum used to called the different endpoints.
///
/// - getStops: Get all Stops.
/// - getPhysicalStops: Get all physical stops.
/// - getNextDepartures: Get next departures.
/// - getAllNextDepartures: Get all the next departures.
/// - getThermometer: Get the thermometer.
/// - getThermometerPhysicalStops: Get the thermometer for physical stops.
/// - getLinesColors: Get the color for the lines.
/// - getDisruptions: Get the disruptions.
public enum API {

    // MARK: Stops

    case getStops(stopCode: String?, stopName: String?, line: String?, latitude: Float?, longitude: Float?)
    case getPhysicalStops(stopCode: String?, stopName: String?)

    // MARK: Departures
    case getNextDepartures(stopCode:String, departureCode:String?, linesCode:String?, destinationsCode:String?)
    case getAllNextDepartures(stopCode:String, linesCode:String, destinationsCode:String)

    // MARK: Thermometers
    case getThermometer(departureCode: String)
    case getThermometerPhysicalStops(departureCode: String)

    // MARK: LineColors
    case getLinesColors

    // MARK: Disruptions
    case getDisruptions
}


/// JSONMarshable represents an item
/// that can be convertible to JSON.
public protocol JSONMarshable {
    init?(json: [String:Any])
}
