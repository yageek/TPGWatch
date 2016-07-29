//
//  WatchProxy.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData
import Operations

class WatchProxy: NSObject, WCSessionDelegate {

    let session: WCSession
    var lastState: WCSessionActivationState = .NotActivated

    let queue = OperationQueue()

    init(session: WCSession) {
        self.session = session
        super.init()

        session.delegate = self
        session.activateSession()

    }

    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {

        if let error = error {
            print("Impossible to acvitate session: \(error)")
            return
        }
        guard activationState == .Activated && lastState != .Activated else { print("Do not need to send data"); return }

        //sendLinesRegistery()
        sendBookmarkedStops()
    }

    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {

        if let error = error {
            print("Impossible to transfer element to the watch: \(error)")
        } else {
            print("Data transmitted correctly to the watch")
        }
    }


    func sendBookmarkedStops() {

        print("Sending stop to the watch....")
        
        let request = NSFetchRequest(entityName: Stop.EntityName)
        request.predicate = NSPredicate(format: "bookmarked == true")
        request.propertiesToFetch = ["code", "name"]
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let stopsObjects = try UIMoc().executeFetchRequest(request) as! [Stop]
            let stops = stopsObjects.map({ (stop) -> [String:AnyObject] in
                return [
                    "name" : stop.name!,
                    "code" : stop.code!
                ]
            })

            let dict: [String: AnyObject] = ["stops": stops]
            try session.updateApplicationContext(dict)

        } catch let error {
            print("Can not send error:\(error)")
        }
    }


}
