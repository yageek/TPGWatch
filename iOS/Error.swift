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
    case apiError
}

extension GeneralError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noNetworkConnection:
            return NSLocalizedString("No internet connection is available", comment: "")
        case .unexpectedData:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        case .serviceUnavailable:
            return NSLocalizedString("The TPG server is unavailable.", comment: "")
        case .unexpectedError:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        case .apiError:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        }
    }
    public var failureReason: String? {
        switch self {
        case .noNetworkConnection:
            return NSLocalizedString("No internet connection is available", comment: "")
        case .unexpectedData:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        case .serviceUnavailable:
            return NSLocalizedString("The TPG server is unavailable.", comment: "")
        case .unexpectedError:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        case .apiError:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .noNetworkConnection:
            return NSLocalizedString("No internet connection is available", comment: "")
        case .unexpectedData:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        case .serviceUnavailable:
            return NSLocalizedString("The TPG server is unavailable.", comment: "")
        case .unexpectedError:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        case .apiError:
            return NSLocalizedString("The server returned an unexpected answer", comment: "")
        }
    }
}
extension GeneralError: CustomNSError {
    static var errorDomain = "net.yageek.TPGWatch"

    var errorCode: Int {
        return self.rawValue
    }

    var errorUserInfo: [String: Any] {
        switch self {

        case .noNetworkConnection:
            return [
                NSLocalizedDescriptionKey: errorDescription!,
                NSLocalizedRecoverySuggestionErrorKey: localizedDescription
            ]
        case .unexpectedData:
            return [
                NSLocalizedDescriptionKey: errorDescription!
            ]
        case .serviceUnavailable:
            return [
                NSLocalizedDescriptionKey: errorDescription!,
                NSLocalizedRecoverySuggestionErrorKey: localizedDescription
            ]
        case .unexpectedError:
            return [
                NSLocalizedDescriptionKey: errorDescription!
            ]
        case .apiError:
            return [
                NSLocalizedDescriptionKey: errorDescription!
            ]
        }
    }
}
