//
//  Store.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Foundation
import Operations

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

        let saveOp = SaveOperation(data: data, saveURL: URL)
        let produceOb = DidFinishObserver { (op, errors) in

            if let error = errors.first {
                print("Impossible to save data at \(URL): \(error)")
            } else {
                print("Sucessfully save data at \(URL)")
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: json)
                }
            }
        }

        saveOp.addObserver(produceOb)
        queue.addOperations(saveOp)
    }

    func readBookmarks(completion: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        readArrayData(Store.StopsFileURL, completion: completion)
    }

    func readRegistery(completion: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        readArrayData(Store.RegisteryFileURL, completion: completion)
    }

    func readBookmarksAndRegistery(completion: (bookmarks: [[String: AnyObject]]?, registery: [[String: AnyObject]]?, error: NSError?) -> Void) {

        let readBookOp = ReadOperation(url: Store.StopsFileURL)
        let readRegisteryOp = ReadOperation(url: Store.RegisteryFileURL)

        let groupOp = GroupOperation(operations: readBookOp, readRegisteryOp)

        let produceOb = DidFinishObserver { (op, errors) in

            NSOperationQueue.mainQueue().addOperationWithBlock {

                let error = errors.first
                completion(bookmarks: readBookOp.result, registery: readRegisteryOp.result, error: nil)
            }
        }

        groupOp.addObserver(produceOb)

        queue.addOperation(groupOp)
    }

    private func readArrayData(URL: NSURL, completion:(result: [[String: AnyObject]]?, error: NSError?) -> Void) {

        let readOp = ReadOperation(url: URL)
        let producedObserver = DidFinishObserver { (op, errors) in

            NSOperationQueue.mainQueue().addOperationWithBlock {

                let error = errors.first
                completion(result: (op as! ReadOperation).result, error: nil)

            }
        }

        readOp.addObserver(producedObserver)
        queue.addOperation(readOp)

    }

}