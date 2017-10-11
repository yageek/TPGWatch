//
//  ParsedDeviation.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// An API Object representing deviation.
public struct Deviation: Decodable {

    /// The code of the deviation.
    public let code: Double

    /// The starting stop of the deviation.
    public let startStop: Stop?

    /// The ending stop of the deviation.
    public let endStop: Stop?

    public enum CodingKeys: String, CodingKey {
        case code = "deviationCode"
        case startStop
        case endStop
    }
}
