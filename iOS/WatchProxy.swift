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
import ProcedureKit
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
        session.activate()

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

        if let error = error {
            print("Impossible to acvitate session: \(error)")
            return
        }

        syncData()
    }

    func syncData() {
        let sendRegisteryOp = SendRegisteryProcedure(context: UIMoc(), proxy: self)
        let sendBookmarkOp = SendBookmarkOperation(context: UIMoc(), proxy: self)

        queue.add(operations: sendRegisteryOp, sendBookmarkOp)

    }

    func sendData(_ data: [String: Any]) throws {

        try session.updateApplicationContext(data)
    }

    func sendBookmarkedStops () {
        let sendBookmarkOp = SendBookmarkOperation(context: UIMoc(), proxy: self)
        queue.addOperation(sendBookmarkOp)
    }


}
