//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import CoreLocation
import MapKit
import ProcedureKit
import TestingProcedureKit
@testable import ProcedureKitLocation

class ReverseGeocodeProcedureTests: LocationProcedureTestCase {

    func test__geocoder_starts() {
        geocoder.placemarks = [placemark]
        let procedure = ReverseGeocodeProcedure(location: location)
        procedure.geocoder = geocoder
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
        XCTAssertEqual(geocoder.didReverseGeocodeLocation, location)
    }

    func test__geocoder_returns_error_finishes_with_error() {
        let error = TestError()
        geocoder.error = error
        let procedure = ReverseGeocodeProcedure(location: location)
        procedure.geocoder = geocoder
        wait(for: procedure)
        PKAssertProcedureFinishedWithError(procedure, error)
        XCTAssertEqual(geocoder.didReverseGeocodeLocation, location)
    }

    func test__geocoder_cancels_when_cancelled() {
        let procedure = ReverseGeocodeProcedure(location: location)
        procedure.geocoder = geocoder
        check(procedure: procedure) { $0.cancel() }
        XCTAssertTrue(geocoder.didCancel)
    }

    func test__result_is_set() {
        geocoder.placemarks = [placemark]
        let procedure = ReverseGeocodeProcedure(location: location)
        procedure.geocoder = geocoder
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
        XCTAssertNotNil(procedure.output.success)
        XCTAssertEqual(procedure.output.success, geocoder.placemarks?.first)
    }

    func test__completion_is_executed_and_receives_placemark() {
        weak var exp = expectation(description: "Test: \(#function)")
        var didReceivePlacemark: CLPlacemark? = nil
        geocoder.placemarks = [placemark]
        let procedure = ReverseGeocodeProcedure(location: location) { placemark in
            didReceivePlacemark = placemark
            exp?.fulfill()
        }
        procedure.geocoder = geocoder
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
        XCTAssertNotNil(didReceivePlacemark)
        XCTAssertEqual(didReceivePlacemark, geocoder.placemarks?.first)
    }

    func test__completion_is_executed_on_main_queue() {
        weak var exp = expectation(description: "Test: \(#function)")
        var didRunCompletionBlockOnMainQueue = false
        geocoder.placemarks = [placemark]
        let procedure = ReverseGeocodeProcedure(location: location) { _ in
            didRunCompletionBlockOnMainQueue = DispatchQueue.isMainDispatchQueue
            exp?.fulfill()
        }
        procedure.geocoder = geocoder
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
        XCTAssertTrue(didRunCompletionBlockOnMainQueue)
    }
}


