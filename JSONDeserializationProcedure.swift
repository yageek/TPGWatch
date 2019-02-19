//
//  JSONDeserializationProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 16.11.16.
//  Copyright © 2016 Vitactiv. All rights reserved.
//

import ProcedureKit

public final class JSONDeserializationProcedure<T: Decodable>: Procedure, InputProcedure, OutputProcedure {

    public var input: Pending<URL> = .pending
    public var output: Pending<ProcedureResult<T>> = .pending

    let json: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    override init() {
        super.init()

        name = "Unmarshal \(input)"
    }

    public override func execute() {
        guard let url = input.value else {
            finish(with: ProcedureKitError.requirementNotSatisfied())
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let element = try json.decode(T.self, from: data)
            print("Elements decoded \(element)")
            self.finish(withResult: .success(element))

        } catch let error {
            print("Finish with error: \(error)")
            self.finish(with: error)
        }
    }
}
