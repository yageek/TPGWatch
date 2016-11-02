//
//  JSONUnmarshalOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit

final class JSONUnmarshalOperation: Procedure {


    var requirement: URL?
    var result: Any?

    override init() {
        super.init()
        self.name = "Unmarshal operation"
    }

    override func execute() {
        guard !isCancelled else { return }
        
        guard let requirement = requirement else { return }
        
        guard let stream = InputStream(url: requirement) else {
            finish()
            return;
        }

        stream.open()

        defer {
            stream.close()
        }

        do {
            result = try JSONSerialization.jsonObject(with: stream, options: [])
            self.finish()
        } catch let error {
            self.finish(withError: error)
            return
        }
    }
}
