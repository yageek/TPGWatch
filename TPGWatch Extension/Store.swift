//
//  Store.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Foundation

class Store {

    static let sharedInstance = Store()
    private init() {}
    
    let queue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .Background
        return queue
    }()

    static let StopsFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("boorkmarked.json")
        return savePath
    }()

    static let RegisteryFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("registery.json")
        return savePath
    }()

    func saveBookmarks(json: AnyObject, notificationName: String) {
        self.saveData(json, URL: Store.StopsFileURL, notificationName: notificationName)
    }

    func saveRegistery(json: AnyObject, notificationName: String) {
        self.saveData(json, URL: Store.RegisteryFileURL, notificationName: notificationName)
    }


    private func saveData(json: AnyObject?, URL: NSURL, notificationName: String) {
        guard let data = json else { return }

        let saveOp = SaveOperation(data: data, saveURL: Store.StopsFileURL)

        let notificationOp = NSBlockOperation {

            NSOperationQueue.mainQueue().addOperationWithBlock {
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: json)
            }

        }

        saveOp.addDependency(notificationOp)
        queue.addOperations(saveOp, notificationOp)
    }

    func readBookmarks(completion: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        readArrayData(Store.StopsFileURL, completion: completion)
    }

    func readRegistery(completion: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        readArrayData(Store.RegisteryFileURL, completion: completion)
    }

    private func readArrayData(URL: NSURL, completion:(result: [[String: AnyObject]]?, error: NSError?) -> Void) {

        let op = NSBlockOperation {
            if let stops = NSArray(contentsOfURL: URL) as? [[String: AnyObject]] {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    completion(result: stops, error: nil)
                }

            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    completion(result: nil, error: NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }

        queue.addOperation(op)
    }

}