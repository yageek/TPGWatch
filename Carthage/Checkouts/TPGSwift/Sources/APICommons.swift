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
    static let Host = "https://prod.ivtr-od.tpg.ch/v1"
    /// The host of the TPG server. Equals "https://prod.ivtr-od.tpg.ch/v1".
    public static let HostURL  = Foundation.URL(string:Host)!
}
