//
//  BookmarkedStop.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit

class BookmarkedStop: NSObject {
    @IBOutlet var stopLabel: WKInterfaceLabel!

    //First
    @IBOutlet var lineGroupOne: WKInterfaceGroup!
    @IBOutlet var lineLabelOne: WKInterfaceLabel!

    //Two
    @IBOutlet var lineGroupTwo: WKInterfaceGroup!
    @IBOutlet var lineLabelTwo: WKInterfaceLabel!

    //Three
    @IBOutlet var lineGroupThree: WKInterfaceGroup!
    @IBOutlet var lineLabelThree: WKInterfaceLabel!

    //Second
    @IBOutlet var lineGroupFour: WKInterfaceGroup!
    @IBOutlet var lineLabelFour: WKInterfaceLabel!

    @IBOutlet var moreLabel: WKInterfaceLabel!

    func labels() -> [WKInterfaceLabel?] {
        return [lineLabelOne, lineLabelTwo, lineLabelThree, lineLabelFour]
    }

    func groups() -> [WKInterfaceGroup?] {
        return [lineGroupOne, lineGroupTwo, lineGroupThree, lineGroupFour]
    }

    func setHideLineAtIndex(_ index: Int, hidden: Bool) {
        groups()[index]?.setHidden(hidden)
    }

    func setLine(_ index: Int, text: String, textColor: UIColor, backgroundColor: UIColor) {

        let group = groups()[index]
        group?.setBackgroundColor(backgroundColor)

        let label = labels()[index]

        label?.setText(text)
        label?.setTextColor(textColor)

        setHideLineAtIndex(index, hidden: false)
    }

    func hideAllLines() {
        for i in 0..<groups().count {
            setHideLineAtIndex(i, hidden: true)
        }
        self.moreLabel.setHidden(true)
    }
}
