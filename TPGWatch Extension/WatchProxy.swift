//
//  WatchProxy.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 03.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchProxy: NSObject, WCSessionDelegate {

    static let BookmarkUpdateNotification = "net.yageek.TPGWatch.watchkitapp.watchkitextension.bookmarkupdate"
    static let RegisteryUpdateNotification = "net.yageek.TPGWatch.watchkitapp.watchkitextension.registeryupdate"

    static let sharedInstance = WatchProxy()
    
    let session = WCSession.default()

    fileprivate override init() {
         super.init()
    }

    func startSession() {
        session.delegate = self
        session.activate()
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[watch] Session changed with state:\(activationState)")
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let stopsData = applicationContext["stops"] as? [[String: Any]] {
            Store.sharedInstance.saveBookmarks(stopsData as AnyObject, notificationName: WatchProxy.BookmarkUpdateNotification)
        }

        if let registery = applicationContext["registery"] as? [String: Any] {
            Store.sharedInstance.saveRegistery(registery as AnyObject, notificationName: WatchProxy.RegisteryUpdateNotification)
        }
        
    }
}
