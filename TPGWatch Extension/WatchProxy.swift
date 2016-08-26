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
    
    let session = WCSession.defaultSession()

    private override init() {
         super.init()
    }

    func startSession() {
        session.delegate = self
        session.activateSession()
    }


    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        print("[watch] Session changed with state:\(activationState)")
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let stopsData = applicationContext["stops"] as? [[String: AnyObject]] {
            Store.sharedInstance.saveBookmarks(stopsData, notificationName: WatchProxy.BookmarkUpdateNotification)
        }

        if let registery = applicationContext["registery"] as? [String: AnyObject] {
            Store.sharedInstance.saveRegistery(registery, notificationName: WatchProxy.RegisteryUpdateNotification)
        }
        
    }
}