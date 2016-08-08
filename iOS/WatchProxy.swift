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
import TPGSwift

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


    func sendData(data: [String: AnyObject]) {

        guard session.activationState != .NotActivated else {
            print("There is no active session")
            return
        }
        
        do {
            try session.updateApplicationContext(data)
        } catch let error {
            print("Can not send data to watch: \(error)")
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

                let connections = stop.valueForKeyPath("connections.line.code")?.allObjects ?? []

                return [
                    "name" : stop.name!,
                    "code" : stop.code!,
                    "lines": connections,
                ]
            })

            let dict: [String: AnyObject] = ["stops": stops]
            sendData(dict)

        } catch let error {
            print("Can not send error:\(error)")
        }
    }


}
