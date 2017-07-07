//
//  URLSerialization.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 05.07.17.
//  Copyright © 2017 yageek's company. All rights reserved.
//

import XCTest
import TPGSwift

class URLSerialization: XCTestCase {

    static let fakeKey = "KEY"

    override func setUp() {
        super.setUp()
        API.Key = URLSerialization.fakeKey
    }

    func testSerialization() {
        assertURL(API.getDisruptions, path: "/GetDisruptions.json")
        assertURL(API.getStops(stopCode: "stopCode", stopName: nil, line: nil, latitude: nil, longitude: nil), path: "/GetStops.json?stopCode=stopCode")
    }

    func assertURL(_ api: @autoclosure () -> API, path: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {

        guard let url = URL(string: path()) else {
            XCTFail("invalid url: \(path())",  file: file, line: line)
            return
        }

        guard let urlPath = URL(string: API.HostURL.path) else {
            XCTFail("invalid path: \(path())",  file: file, line: line)
            return
        }

        var pathURLString = urlPath.appendingPathComponent(url.path).absoluteString
        if let query = url.query {
            pathURLString.append("?\(query)")
        }

        guard let fullURL = URL(string: pathURLString) else {
            XCTFail("invalid path: \(path())",  file: file, line: line)
            return
        }
        var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)!
        components.host = API.HostURL.host
        components.scheme = API.HostURL.scheme

        var items: [URLQueryItem] = [URLQueryItem(name: "key", value: URLSerialization.fakeKey)]

        if let components = components.queryItems {
            items.append(contentsOf: components)
        }

        components.queryItems = items
        let computedURLString = components.url!.absoluteString
        XCTAssertEqual(api().URL.absoluteString, computedURLString, file: file, line: line)
    }
}
