//
//  Test.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 20/11/2024.
//

import JSONStat
import Testing

struct Test {
    @Test func unsupportedVersion() throws {
        let json = """
        {
            "version": "3.0"
        }
        """
        #expect(throws: DecodeError.unsupportedVersion) {
            try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        }
    }

    @Test func unsupportedUpdatedFormat() throws {
        let json = """
        {
            "version": "2.0",
            "updated": "invalid",
            "class": "dataset",
            "id": [],
            "size": [],
            "value": [],
            "dimension": {}
        }
        """
        #expect(throws: DecodeError.unsupportedUpdatedFormat(dateString: "invalid")) {
            try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        }
    }
}
