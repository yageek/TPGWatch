//
//  ParsedThermometer.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 17.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

public struct ParsedThermometer: JSONMarshable {

    public let timestamp: Date
    public let stop: ParsedStopsRecord

    public let lineCode: Double
    public let destinationName: String
    public let destinationCode: String

    public let deviations: [ParsedDeviation]
    public let disruptions: [ParsedDisruption]


    public init?(json: [String:Any]) {

        guard let therm = json["thermometer"] as? [String: AnyObject] else { return nil }

        guard let date = therm["timestamp"] as? String,
              let code = therm["lineCode"] as? Double,
              let destCode = therm["destinationCode"] as? String,
              let destName = therm["destinationName"] as? String,
              let stopRaw = therm["stop"] as? [String:Any],
              let deviationsRaw = therm["deviations"] as? [[String:Any]],
              let disruptionsRaw = therm["disruptions"] as? [[String:Any]] else { return nil }


        guard
            let timestampValue = API.TimestampFormatter.date(from: date),
            let stopStruct = ParsedStopsRecord(json: stopRaw) else { return nil }


        timestamp = timestampValue
        stop = stopStruct

        lineCode = code
        destinationCode = destCode
        destinationName = destName

        deviations = deviationsRaw.flatMap { ParsedDeviation(json: $0) }
        disruptions = disruptionsRaw.flatMap { ParsedDisruption(json: $0) }

    }

    public struct Step: JSONMarshable {

        public let stop: ParsedStopsRecord
        public let departureCode: Double
        public let deviationCode: Double?
        public let timestamp: Date
        public let arrivalTime: Double
        public let reliability: String
        public let deviation: Bool
        public let visible: Bool


        public init?(json: [String:Any]) {

            guard let stopRaw = json["stop"] as? [String:Any],
            let depCode = json["departureCode"] as? Double,
            let date = json["timestamp"] as? String,
            let time = json["arrivalTime"] as? Double,
            let rel = json["reliability"] as? String,
            let dev = json["deviation"] as? Bool,
            let vis = json["visible"] as? Bool else { return nil }


            guard let stopUnserialized = ParsedStopsRecord(json: stopRaw) else { return nil }
            guard let timeStampValue = API.TimestampFormatter.date(from: date) else { return nil }

            stop = stopUnserialized
            departureCode = depCode
            timestamp = timeStampValue
            arrivalTime = time
            reliability = rel
            deviation = dev
            visible = vis

            deviationCode = json["deviationCode"] as? Double

        }

    }

}
