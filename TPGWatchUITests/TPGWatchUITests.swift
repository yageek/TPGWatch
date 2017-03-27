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
        app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()

        let exp = self.expectation(description: "Screenshots")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {

            snapshot("02Searchs")

            // Click on search
            let tablesQuery = app.tables
            var searchField = tablesQuery.searchFields.element(boundBy: 0)
            searchField.tap()

            //Enter text
            searchField = app.searchFields.element(boundBy: 0)
            searchField.tap()
            searchField.typeText("Gare")
            snapshot("03SearchsFilled")

            //Cancel
            let abbrechenButton = app.buttons.element(boundBy: 1)
            abbrechenButton.tap()


            tablesQuery.children(matching: .cell).element(boundBy: 1).staticTexts.element(boundBy: 0).tap()
            tablesQuery.children(matching: .cell).element(boundBy: 2).staticTexts.element(boundBy: 0).tap()

            snapshot("04SearchsSelected")
            app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()

            // Type text
            // Cancel
            // Select first
            // Back
            // Screenshots
            snapshot("05Bookmarks")
            exp.fulfill()

        }

        self.waitForExpectations(timeout: 300) { (error) in
            if let error = error {
                print("Impossible to take screenshots: \(error)")
            }
        }

    }
    
}
