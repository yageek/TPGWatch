//
//  SyncController.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import Foundation
import ProcedureKit

class SyncController: WKInterfaceController {

    let queue = ProcedureKit.OperationQueue()

    @IBOutlet var startLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        startCleanup()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        NotificationCenter.default.addObserver(self, selector: #selector(registeryHasBeenUpdate), name: NSNotification.Name(rawValue: WatchProxy.RegisteryUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registeryHasBeenUpdate), name: NSNotification.Name(rawValue: WatchProxy.BookmarkUpdateNotification), object: nil)

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()

        NotificationCenter.default.removeObserver(self)
    }

    func startCleanup() {
        let cleanUpOp = InitProcedure(label: startLabel, root: self)


//        let finishObserver = DidFinishObserver<InitProcedure> { (_, _) in
//            WatchProxy.sharedInstance.startSession()
//        }

        //cleanUpOp.addObserver(finish)
//        cleanUpOp.add(observer: finish)
        queue.addOperation(cleanUpOp)
    }


    func registeryHasBeenUpdate(_ notification: Notification) {

        if Store.sharedInstance.registeryCache != nil && Store.sharedInstance.bookmarkCache != nil {
            WKInterfaceController.reloadRootControllers(withNames: ["BookmarkStopInterfaceController"], contexts: [])
        }
    }
}
