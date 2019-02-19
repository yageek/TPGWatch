# TPGSwift

Swift libary for the TPG Open Data.

For more explanation: [TPG Open Data](http://www.tpg.ch/fr/web/open-data/mode-d-emploi)

[![Build Status](https://travis-ci.org/yageek/TPGSwift.svg?branch=master)](https://travis-ci.org/yageek/TPGSwift)

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
 [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPGSwift.svg)](https://img.shields.io/cocoapods/v/TPGSwift.svg)
 [![Platform](https://img.shields.io/cocoapods/p/TPGSwift.svg?style=flat)](http://cocoadocs.org/docsets/TPGSwift)

## Usage

```swift
import TPGSwift

// MARK: - Setting the key

// Set the API Key
API.Key = "MY_API_KEY"

// MARK: - Creating an API call url

// Get stops for the stop code "WTC0"
let getStops = API.getStops(stopCode: "WTC0", stopName: nil, line: nil, latitude: nil, longitude: nil)

print("API Stops: \(getStops.URL)")
// -> API Stops: https://prod.ivtr-od.tpg.ch/v1/GetStops.json?key=KEY&stopCode=WTC0

// MARK: - Decode

let json = JSONDecoder()
// This is mandatory
decoder.dateDecodingStrategy = .iso8601

do {
    let stops = try json.decode(Record<Stop>.self, from: data)
    print("Stops: \(stops)")
} catch let error {
    print("Error: \(error)")
}

```

## Paw

You can find a basic Paw file which will help you to play with the API.
Open `TPGSwift.paw` and change the `KEY` variable in the `Production` group
with the one received from the TPG.

## License

TPGSwift is released under the MIT license. See LICENSE for details.
