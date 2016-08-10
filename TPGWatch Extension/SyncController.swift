//
//  SyncController.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import Foundation
import Operations

class SyncController: WKInterfaceController {

    let queue = OperationQueue()

    @IBOutlet var startLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        startCleanup()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(registeryHasBeenUpdate), name: WatchProxy.RegisteryUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(registeryHasBeenUpdate), name: WatchProxy.BookmarkUpdateNotification, object: nil)

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func startCleanup() {
        let cleanUpOp = InitOperation(label: startLabel, root: self)


        let finish = DidFinishObserver { (operation, errors) in
            WatchProxy.sharedInstance.startSession()
        }

        cleanUpOp.addObserver(finish)
        queue.addOperation(cleanUpOp)
    }


    func registeryHasBeenUpdate(notification: NSNotification) {

        if Store.sharedInstance.registeryCache != nil && Store.sharedInstance.bookmarkCache != nil {
            WKInterfaceController.reloadRootControllersWithNames(["BookmarkStopInterfaceController"], contexts: [])
        }
    }
}
