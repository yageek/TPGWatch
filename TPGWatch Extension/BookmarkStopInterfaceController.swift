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
import Operations

class BookmarkedStop: NSObject {
    @IBOutlet var stopLabel: WKInterfaceLabel!
}

class BookmarkStopInterfaceController: WKInterfaceController {

    @IBOutlet var bookmarkedStopsTable: WKInterfaceTable!
    @IBOutlet var noElementGroups: WKInterfaceGroup!

    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .Background
        return queue
    }()

    var lastStops: [[String: AnyObject]]?


    override func willActivate() {
        super.willActivate()
        readData()
    }

    override func didAppear() {
        super.didAppear()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(bookmarkNotification), name: WatchProxy.BookmarkUpdateNotification, object: nil)
    }

    override func willDisappear() {
        super.willDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func reloadData() {

        guard let stops = lastStops else { return }

        bookmarkedStopsTable.setNumberOfRows(stops.count, withRowType: "BookmarkedStop")
        let rowCount = bookmarkedStopsTable.numberOfRows
        self.noElementGroups.setHidden(rowCount != 0)

        for i in 0 ..< rowCount {

            let row = bookmarkedStopsTable.rowControllerAtIndex(i) as! BookmarkedStop
            let stopName = stops[i]["name"] as! String
            row.stopLabel.setText(stopName)
        }

    }


    func readData() {
        
        let op = NSBlockOperation {
            if let stops = NSArray(contentsOfURL: WatchProxy.sharedInstance.stopsFileURL)  {
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

        let context = [
            "stop": stop
        ]

        self.pushControllerWithName("DeparturesInterfaceController", context: context)
    }

    // MARK: Notification
    func bookmarkNotification(notif: NSNotification) {
        lastStops = notif.object as? [[String:AnyObject]]
        self.reloadData()
    }
}
