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

        snapshot("01BookmarksEmpty")
        //Click on "+" button.
        app.navigationBars.elementBoundByIndex(0).buttons.elementBoundByIndex(0).tap()

        let exp = self.expectationWithDescription("Screenshots")

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {

            snapshot("02Searchs")

            // Click on search
            let tablesQuery = app.tables
            var searchField = tablesQuery.searchFields.elementBoundByIndex(0)
            searchField.tap()

            //Enter text
            searchField = app.searchFields.elementBoundByIndex(0)
            searchField.tap()
            searchField.typeText("Gare")
            snapshot("03SearchsFilled")

            //Cancel
            let abbrechenButton = app.buttons.elementBoundByIndex(1)
            abbrechenButton.tap()


            tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(1).staticTexts.elementBoundByIndex(0).tap()
            tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(2).staticTexts.elementBoundByIndex(0).tap()

            snapshot("04SearchsSelected")
            app.navigationBars.elementBoundByIndex(0).buttons.elementBoundByIndex(0).tap()

            // Type text
            // Cancel
            // Select first
            // Back
            // Screenshots
            snapshot("05Bookmarks")
            exp.fulfill()

        }

        self.waitForExpectationsWithTimeout(300) { (error) in
            if let error = error {
                print("Impossible to take screenshots: \(error)")
            }
        }

    }
    
}
