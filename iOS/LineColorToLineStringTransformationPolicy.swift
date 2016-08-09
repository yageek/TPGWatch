//
//  LineColorToLineStringTransformationPolicy.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import CoreData
import UIKit

class LineColorToLineStringTransformationPolicy: NSEntityMigrationPolicy {

    func colorToColorHex(color: UIColor) -> String {
        return color.hexString
    }
}
