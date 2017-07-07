//
//  Connection.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation

/// ParsedConnection is a model containing the element from
/// the API.
public struct Connection: Decodable {

    /// The code of the line.
    public let lineCode: String

    /// The name of the destination.
    public let destinationName: String

    /// The code of the destination.
    public let destinationCode: String

}
