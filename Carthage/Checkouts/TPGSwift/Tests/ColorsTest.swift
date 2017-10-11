//
//  ColorsTest.swift
//  TPGSwiftTests-iOS
//
//  Created by Yannick Heinrich on 05.07.17.
//  Copyright © 2017 yageek's company. All rights reserved.
//

import XCTest
@testable import TPGSwift

class ColorsTest: XCTestCase {

    func testColorConversion() {
        XCTAssertNoThrow(try colorFromString(hex: "CC3399"))
    }
}
