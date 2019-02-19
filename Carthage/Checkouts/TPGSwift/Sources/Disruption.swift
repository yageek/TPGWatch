//
//  ParsedDisruption.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 12.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// A Disruption object
public struct Disruption: Decodable, APIObject {

    public static var recordName = "disruptions"
    /// The code of the disruption
    public let code: Int?

    // The code of the concerned line.
    public let lineCode: String?

    /// The date
    public let timestamp: Date

    /// The place of the disruption
    public let place: String

    /// The nature of disruption
    public let nature: String

    /// The consequence of disruption
    public let consequence: String

    enum CodingKeys: String, CodingKey {
        case code = "disruptionCode"
        case timestamp
        case place
        case nature
        case consequence
        case lineCode
    }

}
