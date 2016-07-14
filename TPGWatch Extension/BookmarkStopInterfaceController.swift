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

    let stopsFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("boorkmarked.json")
        return savePath
    }()

    let registeryURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("registery.json")
        return savePath
    }()

    let session = WCSession.defaultSession()
    var lastStops: [[String: AnyObject]]?
    var registery: [[String: AnyObject]]?

    let queue: NSOperationQueue = {
        let q = NSOperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        session.delegate = self
        session.activateSession()

    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        readData()
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

            print("Received Last Data: \(lastStops)")
            saveData(stopsData, URL: self.stopsFileURL)
            lastStops = stopsData

            dispatch_async(dispatch_get_main_queue()){
                self.reloadData()
            }

        } else if let registery = userInfo["registery"] as? [[String: AnyObject]] {
                print("Received Registery")
                self.registery = registery
                saveData(registery, URL: self.registeryURL)
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


    func saveData(json: [[String :AnyObject]]?, URL: NSURL) {
        guard let data = json else { return }

        let op = NSBlockOperation {
            let stops = data as NSArray

            if !stops.writeToURL(URL, atomically: true) {
                print("Can not save :(")
            } else {
                print("Correctly saved :)")
            }
        }
        queue.addOperation(op)
    }

    func readData() {

        let op = NSBlockOperation {
            if let stops = NSArray(contentsOfURL: self.stopsFileURL)  {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let s = stops as! [[String:AnyObject]]
                    self.lastStops = s
                    self.reloadData()
                }
            } else {
                print("Can not read elements :(")
            }
        }

        queue.addOperation(op)
    }

    // MARK: Table

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        guard let stop = self.lastStops?[rowIndex] else {
            return
        }
        let context = ["stop": stop]

        self.pushControllerWithName("DeparturesInterfaceController", context: context)
    }
}
