//
//  APIKey.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation


// MARK: - Server informations.
public extension API {

    /// The API key provided by the TPG.
    public static var Key: String?

    /// The host of the TPG server. Equals "http://prod.ivtr-od.tpg.ch/v1".
    public static let Host = "http://prod.ivtr-od.tpg.ch/v1"

    /// The formatter for all the date used within the API.
    public static let TimestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    public static let HostURL  = Foundation.URL(string:Host)!
}
