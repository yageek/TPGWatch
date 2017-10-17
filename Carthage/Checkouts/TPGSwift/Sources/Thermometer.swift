//
//  ParsedThermometer.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 17.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// A Thermometer response
public struct Thermometer: Decodable {
    /// The date when the response has been generated
    public let timestamp: Date

    /// The concerned stop
    public let stop: Stop

    /// The ode of the line
    public let lineCode: String

    /// The name of the destination
    public let destinationName: String

    /// The code of the destination
    public let destinationCode: String

    /// The potential deviations
    public let deviations: [Deviation]?

    /// The potential disruptions
    public let disruptions: [Disruption]?

    /// The steps of the thermometer
    public let steps: [Step]
}

/// The different step of a thermometers
public struct Step: Decodable {

    /// The concerned stop
    public let stop: Stop

    /// The code of the departure
    public let departureCode: Double

    /// The code of the deviation
    public let deviationCode: Double?

    /// Some timestamp value
    public let timestamp: Date

    /// The arrival time if the schedure reference is provided
    public let arrivalTime: String?

    /// The reliabilty
    public let reliability: String

    /// If it is a deviation
    public let deviation: Bool

    /// If the stop correspond to the departure code
    public let visible: Bool
}
