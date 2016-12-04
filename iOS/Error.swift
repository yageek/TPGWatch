//
//  Error.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation

enum GeneralError: Int, Error {
    case noNetworkConnection
    case unexpectedData
    case serviceUnavailable
    case unexpectedError
}

extension GeneralError {

    static var Domain = "net.yageek.TPGWatch"

    var error: NSError {
        switch self {

        case .noNetworkConnection:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No internet connection is available", comment: ""), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Retry later", comment: "")])
        case .unexpectedData:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The server returned an unexpected answer", comment: "")])
        case .serviceUnavailable:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The TPG server is unavailable.", comment: ""), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Retry later", comment: "")])
        case .unexpectedError:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The server returned an unexpected answer", comment: "")])
        }
    }
}
