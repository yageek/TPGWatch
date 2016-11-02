//
//  Store.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Foundation
import ProcedureKit

class Store {

    static let sharedInstance: Store = { Store() }()

    fileprivate init() {}

    fileprivate(set) var registeryCache: [String: AnyObject]?
    fileprivate(set) var bookmarkCache: [[String: AnyObject]]?

    let queue: ProcedureKit.OperationQueue = {
        let queue = ProcedureKit.OperationQueue()
        queue.qualityOfService = .background
        return queue
    }()

    static let StopsFileURL: URL = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savePath = directory.appendingPathComponent("boorkmarked.plist")
        return savePath
    }()

    static let RegisteryFileURL: URL = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savePath = directory.appendingPathComponent("registery.plist")
        return savePath
    }()

    func saveBookmarks(_ json: AnyObject, notificationName: String) {
        self.bookmarkCache = json as? [[String: AnyObject]]
        self.saveData(json, URL: Store.StopsFileURL, notificationName: notificationName)
    }

    func saveRegistery(_ json: AnyObject, notificationName: String) {
        self.registeryCache = json as? [String: AnyObject]
        self.saveData(json, URL: Store.RegisteryFileURL, notificationName: notificationName)
    }


    fileprivate func saveData(_ json: AnyObject?, URL: Foundation.URL, notificationName: String) {
        guard let data = json else { return }

        let saveOp = SaveOperation(data: data, saveURL: URL)
//        let produceOb = DidFinishObserver<SaveOperation> { (op, errors) in
//
//            if let error = errors.first {
//                print("Impossible to save data at \(URL): \(error)")
//            } else {
//                print("Sucessfully save data at \(URL)")
//                Foundation.OperationQueue.main.addOperation {
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: json)
//                }
//            }
//        }
//
//        saveOp.add(observer: produceOb)
        queue.addOperation(saveOp)
    }

    func readBookmarks(_ completion: @escaping (_ result: [[String: AnyObject]]?, _ error: Error?) -> Void) {

        if let bookmarkCache = bookmarkCache {
            completion(bookmarkCache, nil)
        } else {
            let readOp = ReadArrayOperation(url: Store.StopsFileURL)
//            let producedObserver = DidFinishObserver { (op, errors) in
//
//                OperationQueue.main.addOperation {
//                    let error = errors.first
//                    let result = (op as! ReadArrayOperation).result
//                    self.bookmarkCache = result
//
//                    completion(result: result, error: error)
//                    return Swift.Void
//                }
//            }
//
//            readOp.addObserver(producedObserver)
            queue.addOperation(readOp)
        }
    }

    func readRegistery(_ completion: @escaping (_ result: [String: AnyObject]?, _ error: Error?) -> Void) {

        if let registeryCache = registeryCache {
            completion(registeryCache, nil)
        } else {
            let readOp = ReadDictionaryOperation(url: Store.RegisteryFileURL)
//            let producedObserver = DidFinishObserver { (op, errors) in
//
//                Foundation.OperationQueue.main.addOperation {
//
//                    let error = errors.first
//                    let result = (op as! ReadDictionaryOperation).result
//                    self.registeryCache = result
//                    completion(result: result, error: error)
//                }
//            }
//
//            readOp.addObserver(producedObserver)
            queue.addOperation(readOp)

        }
    }

    func readBookmarksAndRegistery(_ completion: @escaping (_ bookmarks: [[String: AnyObject]]?, _ registery: [String: AnyObject]?, _ error: Error?) -> Void) {

        let readBookOp = ReadArrayOperation(url: Store.StopsFileURL)
        let readRegisteryOp = ReadDictionaryOperation(url: Store.RegisteryFileURL)

        readBookOp.addDependency(readRegisteryOp)
        let groupOp = GroupProcedure(operations: readBookOp, readRegisteryOp)

//        let produceOb = DidFinishObserver { (op, errors) in
//
//            Foundation.OperationQueue.main.addOperation {
//
//                let error = errors.first
//
//                self.registeryCache = readRegisteryOp.result
//                self.bookmarkCache = readBookOp.result
//                
//                completion(bookmarks: readBookOp.result , registery: readRegisteryOp.result, error: error)
//            }
//        }
//
//        groupOp.addObserver(produceOb)

        queue.addOperation(groupOp)
    }


}
