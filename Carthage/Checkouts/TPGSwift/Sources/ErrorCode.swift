//
//  ErrorCode.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 05.07.17.
//  Copyright © 2017 yageek's company. All rights reserved.
//

import Foundation

/// The object returned in case of error
public struct ErrorCode: Decodable {

    /// The date when the response has been generated
    public let timestamp: Date

    /// The error code
    public let errorCode: Int

    /// Some description about the error
    public let errorMessage: String
}
