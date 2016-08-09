//
//  Error.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation

enum GeneralError: Int, ErrorType {
    case NoNetworkConnection
    case UnexpectedData
    case ServiceUnavailable
    case UnexpectedError
}

extension GeneralError {

    static var Domain = "net.yageek.TPGWatch"

    var error: NSError {


        switch self {

        case .NoNetworkConnection:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No internet connection available", comment: ""), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Retry later", comment: "")])
        case .UnexpectedData:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The server returns an unexpected answer", comment: "")])
        case .ServiceUnavailable:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The TPG server is unavailable.", comment: ""), NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Retry later", comment: "")])
        case .UnexpectedError:
            return NSError(domain: GeneralError.Domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The server returns an unexpected answer", comment: "")])
        }
    }
}