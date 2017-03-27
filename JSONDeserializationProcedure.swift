//
//  JSONDeserializationProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 16.11.16.
//  Copyright © 2016 Vitactiv. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork

public enum Resource<T> {
    case none
    case single(T)
    case collection(Array<T>)

    public var allObjects: [T] {

        switch self {
        case .none:
            return []
        case .single(let val):
            return [val]
        case .collection(let elements):
            return elements
        }
    }
    public var value: T? {
        switch self {
        case .collection:
            return nil
        case .single(let t):
            return t
        case .none:
            return .none
        }
    }
 }

public protocol JSONUnmarshable {
    associatedtype Raw: Any
    init?(JSON: Raw)
}


public final class JSONDeserializationProcedure<T: JSONUnmarshable>: Procedure, InputProcedure, OutputProcedure {

    public var input: Pending<URL> = .pending
    public var output: Pending<ProcedureResult<Resource<T>>> = .pending

    override init() {
        super.init()

        name = "Unmarshal \(input)"
    }

    public override func execute() {
        guard let url = input.value else {
            finish(withError: ProcedureKitError.requirementNotSatisfied())
            return
        }

        guard let stream = InputStream(url: url) else {
            finish(withError: GeneralError.apiError)
            return;
        }

        stream.open()

        defer {
            stream.close()
        }

        do {
            let JSONValue = try JSONSerialization.jsonObject(with: stream, options: [])

            var result: Resource<T>? = nil

            if let collectionObject = JSONValue as? [T.Raw] {

                result = readCollectionObject(object: collectionObject)
            } else if let singleObject = JSONValue as? T.Raw {

                result = readSingleObject(object: singleObject)

            }

            guard let finalResult = result else {
                self.finish(withError: GeneralError.apiError)
                return
            }

            self.output = .ready(.success(finalResult))
            finish()


        } catch let error {
            self.output = .ready(.failure(error))
        }
    }

    private func readSingleObject<T: JSONUnmarshable>(object: T.Raw) -> Resource<T>? {

        guard let object = T(JSON: object) else { return nil }
        return .single(object)
    }

    private func readCollectionObject<T: JSONUnmarshable>(object: [T.Raw]) -> Resource<T>? {
        let collection = object.flatMap { T(JSON: $0) }

        guard collection.count == object.count else { return nil }
        return .collection(collection)
    }

}
