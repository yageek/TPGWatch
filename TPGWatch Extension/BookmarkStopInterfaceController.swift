//
//  BookmarkStopInterfaceController.swift
//  TPGWatch Extension
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class BookmarkedStop: NSObject {
    @IBOutlet var stopLabel: WKInterfaceLabel!
}

class BookmarkStopInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var bookmarkedStopsTable: WKInterfaceTable!
    let session = WCSession.defaultSession()
    var lastStops: [[String: AnyObject]]?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        session.delegate = self
        session.activateSession()

        let directory = NSFileManager.defaultManager().URLsForDirectory(.UserDirectory, inDomains: .UserDomainMask).first

        if let valid = directory {
            print("URL to store:\(valid)")
        }

    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("Receive file: \(file)")
    }

    func sessionReachabilityDidChange(session: WCSession) {
        print("Session: \(session)")
    }

    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        print("[watch] Session changed with state:\(activationState)")
    }

    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {

        if let stopsData = userInfo["stops"] as? [[String: AnyObject]] {
            lastStops = stopsData
            print("Received Last Data: \(lastStops)")
            reloadData()
        } else {
            print("Invalid Data: \(userInfo)")
        }
     }

    func reloadData() {

        guard let stops = lastStops else { return }

        bookmarkedStopsTable.setNumberOfRows(stops.count, withRowType: "BookmarkedStop")
        let rowCount = bookmarkedStopsTable.numberOfRows

        for i in 0 ..< rowCount {

            let row = bookmarkedStopsTable.rowControllerAtIndex(i) as! BookmarkedStop
            let stopName = stops[i]["name"] as! String
            row.stopLabel.setText(stopName)
        }

    }
}
