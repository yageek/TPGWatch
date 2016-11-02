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
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    return context
}

func Proxy() -> WatchProxy? {
    return (UIApplication.shared.delegate as! AppDelegate).proxy
}
//MARK: Save
internal func save() {

    guard UIMoc().hasChanges else { return }

    do {
        try UIMoc().save()
        sendBookmarkedToWatch()
    } catch let error {
        print("Can not save bookmarks change: \(error)")
    }
}

private func sendBookmarkedToWatch() {
    if let proxy = (UIApplication.shared.delegate as! AppDelegate).proxy {
        proxy.sendBookmarkedStops()
    }

}
