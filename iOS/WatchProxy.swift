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

final class WatchProxy: NSObject, WCSessionDelegate {

    let session: WCSession?

    let queue: ProcedureQueue = {
        let queue = ProcedureQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "net.yageek.tpgwatch.syncqueue"
        return queue
    }()

    static var shared = WatchProxy()
    static var isWatchSupported: Bool {
        return WCSession.isSupported()
    }

    private override init() {

        if WatchProxy.isWatchSupported {
            self.session = WCSession.default
        } else {
            self.session = nil
        }

        super.init()

        session?.delegate = self
        session?.activate()
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
        let moc = Store.shared.viewContext
        let sendRegisteryOp = SendRegisteryProcedure(context: moc, proxy: self)
        let sendBookmarkOp = SendBookmarkProcedure(context: moc, proxy: self)

        queue.add(operations: sendRegisteryOp, sendBookmarkOp)

    }

    func sendData(_ data: [String: Any]) throws {
        try session?.updateApplicationContext(data)
    }

    func sendBookmarkedStops () {
        let sendBookmarkOp = SendBookmarkProcedure(context: Store.shared.viewContext, proxy: self)
        queue.addOperation(sendBookmarkOp)
    }
}
