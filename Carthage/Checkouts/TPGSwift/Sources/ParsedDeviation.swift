//
//  ParsedDeviation.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// An API Object representing deviation.
public struct ParsedDeviation: JSONMarshable {


    /// The code of the deviation.
    public let code: Double

    /// The starting stop of the deviation.
    public let startStop: ParsedStopsRecord.ParsedStop?

    /// The ending stop of the deviation.
    public let endStop: ParsedStopsRecord.ParsedStop?
    
    public init?(json: [String:Any]) {

        guard let deviationCode = json["deviationCode"] as? Double else { return nil }

        code = deviationCode

        if let start = json["startStop"] as? [String:Any], let end = json["endStop"] as? [String:Any] {
            startStop = ParsedStopsRecord.ParsedStop(json: start)
            endStop = ParsedStopsRecord.ParsedStop(json: end)
        } else {
            startStop = nil
            endStop = nil
        }
    }
}
