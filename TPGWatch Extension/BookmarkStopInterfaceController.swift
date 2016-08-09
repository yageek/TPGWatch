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


class BookmarkStopInterfaceController: WKInterfaceController {

    @IBOutlet var bookmarkedStopsTable: WKInterfaceTable!
    @IBOutlet var noElementGroups: WKInterfaceGroup!

    var lastStops: [[String: AnyObject]]?
    var registery: [String: AnyObject]?

    override func willActivate() {
        super.willActivate()

        readData()
    }

    override func didAppear() {
        super.didAppear()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(bookmarkNotification), name: WatchProxy.BookmarkUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(registeryNotification), name: WatchProxy.RegisteryUpdateNotification, object: nil)
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
            row.hideAllLines()

            row.stopLabel.setText(stopName)


            guard let registery = self.registery else {
                return;
            }

            //Fill lines colors
            let linesStops = stops[i]["lines"] as! [String]

            for i in 0..<min(4, linesStops.count) {

                let lineCode = linesStops[i]
                let lineInfo = registery[lineCode] as! [String: AnyObject]

                let textColor = lineInfo["textColor"] as! String
                let backgroundColor = lineInfo["backgroundColor"] as! String

                row.setLine(i, text: linesStops[i], textColor: UIColor(rgba: textColor), backgroundColor: UIColor(rgba: backgroundColor))
            }

            // Hide ellipsis point if needed.
            let hideMore = linesStops.count <= 4
            row.moreLabel.setHidden(hideMore)

        }

    }

    func readData() {

        Store.sharedInstance.readBookmarksAndRegistery { (bookmarks, registery, error) in
            if let bookmarks = bookmarks, registery = registery {
                self.lastStops = bookmarks
                self.registery = registery
                self.reloadData()
            } else {
                print("Can not read elements :(")
            }
        }
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

    func registeryNotification(notif: NSNotification) {
        registery = notif.object as? [String:AnyObject]
        self.reloadData()
    }
}
