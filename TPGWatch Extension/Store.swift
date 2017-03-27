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

    fileprivate(set) var registeryCache: [String: Any]?
    fileprivate(set) var bookmarkCache: [[String: Any]]?

    let queue: ProcedureQueue = {
        let queue = ProcedureKit.ProcedureQueue()
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

    func saveBookmarks(_ json: Any, notificationName: String) {
        self.bookmarkCache = json as? [[String: Any]]
        self.saveData(json, URL: Store.StopsFileURL, notificationName: notificationName)
    }

    func saveRegistery(_ json: Any, notificationName: String) {
        self.registeryCache = json as? [String: Any]
        self.saveData(json, URL: Store.RegisteryFileURL, notificationName: notificationName)
    }


    fileprivate func saveData(_ json: Any?, URL: Foundation.URL, notificationName: String) {
        guard let data = json else { return }

        let saveOp = SaveProcedure(data: data, saveURL: URL)
        saveOp.addDidFinishBlockObserver { (_, errors) in
            if let error = errors.first {
                print("Impossible to save data at \(URL): \(error)")
            } else {
                print("Sucessfully save data at \(URL)")
                Foundation.OperationQueue.main.addOperation {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: json)
                }
            }
        }
        queue.addOperation(saveOp)
    }

    func readBookmarks(_ completion: @escaping (_ result: [[String: Any]]?, _ error: Error?) -> Void) {

        if let bookmarkCache = bookmarkCache {
            completion(bookmarkCache, nil)
        } else {
            let readOp = ReadArrayProcedure(url: Store.StopsFileURL)
            readOp.addDidFinishBlockObserver { (op, errors) in

                ProcedureQueue.main.addOperation {
                    let error = errors.first
                    let result = op.output.success
                    self.bookmarkCache = result
                    completion(result, error)
                }
            }
            queue.addOperation(readOp)
        }
    }

    func readRegistery(_ completion: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {

        if let registeryCache = registeryCache {
            completion(registeryCache, nil)
        } else {
            let readOp = ReadDictionaryOperation(url: Store.RegisteryFileURL)
            readOp.addDidFinishBlockObserver { (op, errors) in

                ProcedureQueue.main.addOperation {
                    let error = errors.first
                    let result = op.output.success
                    self.registeryCache = result
                    completion(result, error)

                }
            }

            queue.addOperation(readOp)

        }
    }

    func readBookmarksAndRegistery(_ completion: @escaping (_ bookmarks: [[String: Any]]?, _ registery: [String: Any]?, _ error: Error?) -> Void) {

        let readBookOp = ReadArrayProcedure(url: Store.StopsFileURL)
        let readRegisteryOp = ReadDictionaryOperation(url: Store.RegisteryFileURL)

        readBookOp.addDependency(readRegisteryOp)
        let groupOp = GroupProcedure(operations: readBookOp, readRegisteryOp)

        groupOp.addDidFinishBlockObserver { (op, errors) in
            ProcedureQueue.main.addOperation {
                let error = errors.first

                self.registeryCache = readRegisteryOp.output.success
                self.bookmarkCache = readBookOp.output.success
                completion(readBookOp.output.success , readRegisteryOp.output.success, error)

            }
        }

        queue.addOperation(groupOp)
    }


}
