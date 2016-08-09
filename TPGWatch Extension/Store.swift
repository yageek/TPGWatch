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

    class var sharedInstance: Store {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Store? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Store()
        }
        return Static.instance!
    }

    private init() {}

    private(set) var registeryCache: [String: AnyObject]?
    private(set) var bookmarkCache: [[String: AnyObject]]?

    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .Background
        return queue
    }()

    static let StopsFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("boorkmarked.plist")
        return savePath
    }()

    static let RegisteryFileURL: NSURL = {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let savePath = directory.URLByAppendingPathComponent("registery.plist")
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

    func readBookmarks(completion: (result: [[String: AnyObject]]?, error: ErrorType?) -> Void) {

        if let bookmarkCache = bookmarkCache {
            completion(result: bookmarkCache, error: nil)
        } else {
            let readOp = ReadArrayOperation(url: Store.StopsFileURL)
            let producedObserver = DidFinishObserver { (op, errors) in

                NSOperationQueue.mainQueue().addOperationWithBlock {

                    let error = errors.first
                    let result = (op as! ReadArrayOperation).result
                    self.bookmarkCache = result
                    completion(result: result, error: error)

                }
            }

            readOp.addObserver(producedObserver)
            queue.addOperation(readOp)
        }
    }

    func readRegistery(completion: (result: [String: AnyObject]?, error: ErrorType?) -> Void) {

        if let registeryCache = registeryCache {
            completion(result: registeryCache, error: nil)
        } else {
            let readOp = ReadDictionaryOperation(url: Store.RegisteryFileURL)
            let producedObserver = DidFinishObserver { (op, errors) in

                NSOperationQueue.mainQueue().addOperationWithBlock {

                    let error = errors.first
                    let result = (op as! ReadDictionaryOperation).result
                    self.registeryCache = result
                    completion(result: result, error: error)
                }
            }

            readOp.addObserver(producedObserver)
            queue.addOperation(readOp)

        }
    }

    func readBookmarksAndRegistery(completion: (bookmarks: [[String: AnyObject]]?, registery: [String: AnyObject]?, error: ErrorType?) -> Void) {

        let readBookOp = ReadArrayOperation(url: Store.StopsFileURL)
        let readRegisteryOp = ReadDictionaryOperation(url: Store.RegisteryFileURL)

        readBookOp.addDependency(readRegisteryOp)
        let groupOp = GroupOperation(operations: readBookOp, readRegisteryOp)

        let produceOb = DidFinishObserver { (op, errors) in

            NSOperationQueue.mainQueue().addOperationWithBlock {

                let error = errors.first

                self.registeryCache = readRegisteryOp.result
                self.bookmarkCache = readBookOp.result
                
                completion(bookmarks: readBookOp.result , registery: readRegisteryOp.result, error: error)
            }
        }

        groupOp.addObserver(produceOb)

        queue.addOperation(groupOp)
    }


}