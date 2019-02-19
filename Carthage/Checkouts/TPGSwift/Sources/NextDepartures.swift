//
//  NextDepartures.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// A NextDepartures response
public struct NextDepartureRecord: Decodable {

    /// The date when the response has been generated
    public let timestamp: Date

    /// The concerned stop
    public let stop: Stop

    /// The next departures
    public let departures: [NextDeparture]

    /// A NextDeparture object
    public struct NextDeparture: Decodable {

        /// The departure code
        public let code: Int?

        /// The waiting time
        public let waitingTime: String

        /// The waiting time in millisecond
        public let waitingTimeMillis: TimeInterval?

        /// The connection waitingTime in millisecond
        public let connectionWaitingTime: TimeInterval?

        /// The reliability
        public let reliability: String?

        /// The concerned line
        public let line: Connection

        /// The characteristics.
        public let characteristics: String?

        /// The ID of the vehicule
        public let vehiculeNo: Int?

        /// The type of the vehicule
        public let vehiculeType: String?

        /// The disruptions
        public let disruptions: [Disruption]?

        enum CodingKeys: String, CodingKey {
            case code = "departureCode"
            case waitingTime
            case waitingTimeMillis
            case connectionWaitingTime
            case reliability
            case line
            case characteristics
            case vehiculeNo
            case vehiculeType
            case disruptions
        }
    }
}
