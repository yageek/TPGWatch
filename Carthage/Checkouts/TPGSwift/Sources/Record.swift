//
//  Record.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 03.07.17.
//  Copyright © 2017 yageek's company. All rights reserved.
//

import Foundation

/// An API object represents an object
/// that can be put in a `Record` object.
public protocol APIObject: Decodable {

    /// The JSON name of the array of elements
    static var recordName: String { get }
}

/// An API object represents an api object
/// with a timestamp and a set of elements.
public struct Record<Object: APIObject>: Decodable {

    /// The date when the response has been generated
    public let timestamp: Date

    /// The elements of the record
    public let elements: [Object]

    enum CodingKeys: String, CodingKey {
        case timestamp
        case elements

        public var stringValue: String {
            switch self {
            case .timestamp: return "timestamp"
            case .elements: return Object.recordName
            }
        }

        /// Initializes `self` from a string.
        ///
        /// - parameter stringValue: The string value of the desired key.
        /// - returns: An instance of `Self` from the given string, or `nil` if the given string does not correspond to any instance of `Self`.
        public init?(stringValue: String) {
            switch stringValue {
            case "timestamp":
                self = .timestamp
            case Object.recordName:
                self = .elements
            default:
                return nil
            }
        }

        /// The int to use in an indexed collection (e.g. an int-keyed dictionary).
        public var intValue: Int? {
            switch self {
            case .timestamp: return 0
            case .elements: return 1
            }
        }

        /// Initializes `self` from an integer.
        ///
        /// - parameter intValue: The integer value of the desired key.
        /// - returns: An instance of `Self` from the given integer, or `nil` if the given integer does not correspond to any instance of `Self`.
        public init?(intValue: Int) {
            switch intValue {
            case 0:
                self = .timestamp
            case 1:
                self = .elements
            default:
                return nil
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        elements = try container.decode([Object].self, forKey: .elements)
    }
}
