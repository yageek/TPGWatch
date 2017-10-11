//
//  DepartureInfo.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit

class DepartureInfo: NSObject {

    @IBOutlet var stopNameLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var lineGroup: WKInterfaceGroup!
    @IBOutlet var lineLabel: WKInterfaceLabel!

    func setLine(_ text: String, textColor: UIColor, backgroundColor: UIColor) {

        let group = lineGroup
        group?.setBackgroundColor(backgroundColor)

        let label = lineLabel

        label?.setText(text)
        label?.setTextColor(textColor)
    }
}
