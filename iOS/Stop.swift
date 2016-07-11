//
//  Stop.swift
//  GenevaNextBus
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Foundation
import CoreData


class Stop: NSManagedObject {

    static let EntityName = "Stop"
    var sectionName: String? {
        get {
            guard let name = self.name else {return nil}
            let ch = name[name.startIndex]
            return String(ch)
        }
    }

}
