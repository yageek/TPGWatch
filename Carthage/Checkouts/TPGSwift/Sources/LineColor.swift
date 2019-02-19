//
//  ParsedLineColorRecord.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

// MARK: - Color conversion

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
    public typealias Color = UIColor
#elseif os(macOS)
    import Cocoa
    public typealias Color = NSColor
#endif

public enum ColorError: Error {
    case invalidRGBString(String)
    case scanError
}

func colorFromString(hex: String) throws -> Color {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0

    let scanner = Scanner(string: hex)
    var hexValue: CUnsignedLongLong = 0
    if scanner.scanHexInt64(&hexValue) {
        switch hex.count {
        case 3:
            red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
            blue  = CGFloat(hexValue & 0x00F)              / 15.0
        case 4:
            red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
            blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
            alpha = CGFloat(hexValue & 0x000F)             / 15.0
        case 6:
            red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
            blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        case 8:
            red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
            alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
        default:
            throw ColorError.invalidRGBString(hex)
        }
    } else {
        throw ColorError.scanError
    }
    return Color(red: red, green: green, blue: blue, alpha: alpha)
}

// MARK: - LineColor

/// A LineColor response.
public struct LineColor: Decodable, APIObject {
    public static var recordName = "colors"

    /// The color of the line (same as background?)
    public let hexa: Color

    /// The code of the line
    public let code: String

    /// The background color (same as hexa?)
    public let background: Color

    /// The color of the text
    public let text: Color

    enum CodingKeys: String, CodingKey {
        case hexa
        case code = "lineCode"
        case background
        case text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hexaString = try container.decode(String.self, forKey: .hexa)
        let backgroundString = try container.decode(String.self, forKey: .background)
        let textString = try container.decode(String.self, forKey: .text)

        self.code = try container.decode(String.self, forKey: .code)
        self.hexa = try colorFromString(hex: hexaString)
        self.background = try colorFromString(hex: backgroundString)
        self.text = try colorFromString(hex: textString)
    }
}
