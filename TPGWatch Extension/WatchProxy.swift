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
            saveData(stopsData, URL: self.stopsFileURL)

        } else {
            print("Invalid Data: \(applicationContext)")
        }
        
    }

    func saveData(json: AnyObject?, URL: NSURL) {
        guard let data = json else { return }

        let op = NSBlockOperation {

            if let array = data as? [[String: AnyObject]] {
                let stops = array as NSArray
                if !stops.writeToURL(URL, atomically: true) {
                    print("Can not save :(")
                } else {
                    print("Correctly saved :)")
                }
            } else if let dict = data as? [String: AnyObject] {
                let registery = dict as NSDictionary

                if !registery.writeToURL(URL, atomically: true) {
                    print("Can not save :(")
                } else {
                    print("Correctly saved :)")
                }
            }
        }

        let notification = NSBlockOperation {
            NSNotificationCenter.defaultCenter().postNotificationName(WatchProxy.BookmarkUpdateNotification, object: json)
        }
        
        notification.addDependency(op)

        queue.addOperations(op)
        NSOperationQueue.mainQueue().addOperation(notification)

    }


}