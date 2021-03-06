//
//  ExtensionDelegate.swift
//  TPGWatch Extension
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import TPGSwift
import ProcedureKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        #if DEBUG
            LogManager.severity = .verbose
        #else
            LogManager.severity = .fatal
        #endif
        API.Key = TPGKey
    }
}
