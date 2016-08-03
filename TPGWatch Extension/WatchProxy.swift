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
    static let sharedInstance = WatchProxy()
    
    let session = WCSession.defaultSession()

    let queue: NSOperationQueue = {
        let q = NSOperationQueue()
        return q
    }()

    let stopsFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("boorkmarked.json")
        return savePath
    }()

    let registeryFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("registery.json")
        return savePath
    }()

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

            print("Last bookmarked received :)")
            saveData(stopsData, URL: self.stopsFileURL, notificationName: WatchProxy.BookmarkUpdateNotification)

        } else if let registery = applicationContext["registery"] as? [[String: AnyObject]] {

            print("Last registery received :)")
            saveData(registery, URL: self.registeryFileURL, notificationName: WatchProxy.BookmarkUpdateNotification)
            
        } else {
            print("Invalid Data: \(applicationContext)")
        }
        
    }

    func saveData(json: AnyObject?, URL: NSURL, notificationName: String) {
        guard let data = json else { return }

        let saveOp = SaveOperation(data: data, saveURL: self.stopsFileURL)

        let notificationOp = NSBlockOperation {

            NSOperationQueue.mainQueue().addOperationWithBlock {
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: json)
            }

        }

        saveOp.addDependency(notificationOp)
        queue.addOperations(saveOp, notificationOp)
    }


}