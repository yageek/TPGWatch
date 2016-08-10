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
    let queue: OperationQueue =  {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "net.yageek.tpgwatch.syncqueue"
        return queue
    }()

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

        syncData()
    }

    func syncData() {
        let sendRegisteryOp = SendRegisteryOperation(context: UIMoc(), proxy: self)
        let sendBookmarkOp = SendBookmarkOperation(context: UIMoc(), proxy: self)

        queue.addOperations(sendRegisteryOp, sendBookmarkOp)

    }

    func sendData(data: [String: AnyObject]) throws {

        try session.updateApplicationContext(data)
    }

    func sendBookmarkedStops () {
        let sendBookmarkOp = SendBookmarkOperation(context: UIMoc(), proxy: self)
        queue.addOperation(sendBookmarkOp)
    }


}
