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

class WatchProxy: NSObject, WCSessionDelegate {

    let session: WCSession
    var lastTransfer: WCSessionUserInfoTransfer?
    var lastState: WCSessionActivationState = .NotActivated

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
        request.resultType = .DictionaryResultType
        request.propertiesToFetch = ["name", "code"]

        do {
            let stops = try UIMoc().executeFetchRequest(request) as! [[String: AnyObject]]

            let dict: [String: AnyObject] = ["stops": stops]
            lastTransfer = session.transferUserInfo(dict)

        } catch let error {
            print("Can not send error:\(error)")
        }


    }
}
