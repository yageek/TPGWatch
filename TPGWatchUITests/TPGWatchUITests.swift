//
//  TPGWatchUITests.swift
//  TPGWatchUITests
//
//  Created by Yannick Heinrich on 17.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import XCTest

class TPGWatchUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

    }

    func testExample() {
        let app = XCUIApplication()
        app.navigationBars["Bookmarks"].buttons["Add"].tap()
        snapshot("01Bookmarks")
        app.tables.searchFields["Search"].tap()
        snapshot("02Searchs")
        app.searchFields["Search"]
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).tap()
        snapshot("02SearchsFilled")

    }
    
}
