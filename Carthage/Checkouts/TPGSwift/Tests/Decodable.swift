//
//  Decodable.swift
//  TPGSwiftTests-iOS
//
//  Created by Yannick Heinrich on 06.06.17.
//  Copyright © 2017 yageek's company. All rights reserved.
//

import XCTest
import Foundation
import TPGSwift

class DecodableTests: XCTestCase {

    var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static let bundle: Bundle = {
        let testBundle = Bundle(for: DecodableTests.self)
        let sampleURL = testBundle.url(forResource: "api_samples", withExtension: "bundle")!
        return Bundle(url: sampleURL)!
    }()

    static func getJSONSample(fileName: String) throws -> Data {
        let url = DecodableTests.bundle.url(forResource: fileName, withExtension: "json")!
        return try Data(contentsOf: url)
    }

    func assertDecode<Obj>(_ type: @autoclosure () -> Obj.Type, fileName: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) where Obj: Decodable {
        do {
            let data = try DecodableTests.getJSONSample(fileName: fileName())
            let _ = try jsonDecoder.decode(type(), from: data)

        } catch let error {
            XCTFail("JSON is not Equals: \(error)", file: file, line: line)
        }
    }

    func testStops() {
        assertDecode(Record<Stop>.self, fileName: "GetStops")
        assertDecode(Record<Stop>.self, fileName: "GetStops2")
    }

    func testPhysicalStops() {
        assertDecode(Record<PhysicalStopInfos>.self, fileName: "GetPhysicalStops")
    }

    func testNextDepartures() {
        assertDecode(NextDepartureRecord.self, fileName: "GetNextDepartures")
        assertDecode(NextDepartureRecord.self, fileName: "GetNextDepartures2")
    }

    func testAllNextDepartures() {
        assertDecode(NextDepartureRecord.self, fileName: "GetAllNextDepartures")
    }

    func testThermometers() {
        assertDecode(Thermometer.self, fileName: "GetThermometer")
        assertDecode(Thermometer.self, fileName: "GetThermometer2")
    }

    func testPhysicalThermometers() {
        assertDecode(Thermometer.self, fileName: "GetThermometerPhysicalStops")
    }

    func testLineColors() {
        assertDecode(Record<LineColor>.self, fileName: "GetLineColors")
    }

    func testErrorCodes() {
         assertDecode(ErrorCode.self, fileName: "ErrorCode")
    }

    func testDisruptions() {
        assertDecode(Record<Disruption>.self, fileName: "GetDisruptions")
    }

}
