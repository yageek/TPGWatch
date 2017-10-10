//
//  APIURLSerialization.swift
//  TPGSwift
//
//  Created by Yannick Heinrich on 11.05.16.
//  Copyright © 2016 yageek's company. All rights reserved.
//

import Foundation


// MARK: - URL serialization.
extension API {

    fileprivate static let StopCodeParameter = "stopCode"
    fileprivate static let StopNameParameter = "stopName"
    fileprivate static let LineParameter = "line"
    fileprivate static let LinesCodeParameter = "linesCode"
    fileprivate static let LongitudeParameter = "longitude"
    fileprivate static let LatitudeParameter = "latitude"
    fileprivate static let DepartureCodeParameter = "departudeCode"
    fileprivate static let DestinationsCodeParameter = "destinationsCode"

    /// The `NSURL` requests corresponding to the current enum value.
    public var URL: Foundation.URL {

        guard let Key = API.Key else { fatalError("API KEY has to been set.") }

        let result:(path: String, parameters: [String:AnyObject?]?) = {
            switch self {

            case .getStops(let stopCode, let stopName, let line, let longitude, let latitude):
                return ("GetStops", [API.StopCodeParameter : stopCode as Optional<AnyObject>, API.StopNameParameter: stopName as Optional<AnyObject>, API.LineParameter: line as Optional<AnyObject>, API.LongitudeParameter: longitude as Optional<AnyObject>, API.LatitudeParameter: latitude as Optional<AnyObject>])
            case .getPhysicalStops(let stopCode, let stopName):
                return ("GetPhysicalStops", [API.StopCodeParameter  : stopCode as Optional<AnyObject>, API.StopNameParameter : stopName as Optional<AnyObject>])
            case .getNextDepartures(let stopCode, let departureCode, let linesCode, let destinationsCode):
                return ("GetNextDepartures", [API.StopCodeParameter  : stopCode as Optional<AnyObject>, API.DepartureCodeParameter: departureCode as Optional<AnyObject>, API.LinesCodeParameter: linesCode as Optional<AnyObject>, API.DestinationsCodeParameter: destinationsCode as Optional<AnyObject>])
            case .getAllNextDepartures(let stopCode, let linesCode, let destinationsCode):
                return ("GetNextDepartures", [API.StopCodeParameter  : stopCode as Optional<AnyObject>, API.LinesCodeParameter: linesCode as Optional<AnyObject>, API.DestinationsCodeParameter: destinationsCode as Optional<AnyObject>])
            case .getThermometer(let departureCode):
                return ("GetThermometer", [API.DepartureCodeParameter : departureCode as Optional<AnyObject>])
            case .getThermometerPhysicalStops(let departureCode):
                return ("GetThermometerPhysicalStops", [API.DepartureCodeParameter  : departureCode as Optional<AnyObject>])
            case .getLinesColors:
                return ("GetLinesColors", nil)
            case .getDisruptions:
                return ("GetDisruptions", nil)
            }
        }()

        var parameters = ["key": Key as AnyObject] as [String:Any]

        if let additionalParameters = result.parameters {
            for (key, value) in additionalParameters {
                parameters[key] = value
            }
        }

        let pathURL = API.HostURL.appendingPathComponent(result.path).appendingPathExtension("json")
        var components = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters.map({ (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: String(describing: value))
        })

        let url = components?.url
        return url!
    }
}
