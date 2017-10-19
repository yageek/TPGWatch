//
//  Stop+CoreDataProperties.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stop {

    @NSManaged var bookmarked: Bool
    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var connections: NSSet?

    @NSManaged func addConnectionsObject(_ value: Connection)
    @NSManaged private var primitiveSectionIdentifier: String?

    @objc dynamic var sectionIdentifier: String? {

        willAccessValue(forKey: "sectionIdentifier")
        let tmp = primitiveSectionIdentifier
        didAccessValue(forKey: "sectionIdentifier")
        if let tmp = tmp {
            return tmp
        }
        let ch = name[name.startIndex]

        let val = String(ch)
        willChangeValue(for: \Stop.sectionIdentifier)
        primitiveSectionIdentifier = val
        didChangeValue(for: \Stop.sectionIdentifier)

        return val
    }

    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "sectionIdentifier" {
            return Set<String>(["name"])
        } else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
}
