//
//  DataHelper.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import UIKit
import CoreData

func UIMoc() -> NSManagedObjectContext {
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    return context
}

func Proxy() -> WatchProxy? {
    return (UIApplication.sharedApplication().delegate as! AppDelegate).proxy
}
//MARK: Save
internal func save() {

    guard UIMoc().hasChanges else { return }

    do {
        try UIMoc().save()
        sendToWatch()
    } catch let error {
        print("Can not save bookmarks change: \(error)")
    }
}

private func sendToWatch() {
    if let proxy = (UIApplication.sharedApplication().delegate as! AppDelegate).proxy {
        proxy.sendBookmarkedStops()
    }

}
