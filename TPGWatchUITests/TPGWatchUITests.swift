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

    func testTakeScreenShots() {
        let app = XCUIApplication()

        app.navigationBars.elementBoundByIndex(0).buttons.elementBoundByIndex(0).tap()
        snapshot("01Bookmarks")

        let exp = self.expectationWithDescription("Screenshots")

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {

            snapshot("02Searchs")
            exp.fulfill()

        }

        self.waitForExpectationsWithTimeout(30) { (error) in
            if let error = error {
                print("Impossible to take screenshots: \(error)")
            }
        }

    }
    
}
