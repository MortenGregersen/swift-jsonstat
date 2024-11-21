//
//  ErrorTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 20/11/2024.
//

@testable import JSONStat
import Testing

struct ErrorTests {
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

    @Test func unsupportedValues() {
        let json = """
        {
            "version": "2.0",
            "updated": "2024-11-20T08:00:00Z",
            "class": "dataset",
            "id": [],
            "size": [],
            "value": 42,
            "dimension": {}
        }
        """
        #expect(throws: DecodeError.unsupportedValues) {
            try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        }
    }

    @Test func unsupportedStatus() {
        let json = """
        {
            "version": "2.0",
            "updated": "2024-11-20T08:00:00Z",
            "class": "dataset",
            "id": [],
            "size": [],
            "value": [],
            "status": true,
            "dimension": {}
        }
        """
        #expect(throws: DecodeError.unsupportedStatus) {
            try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        }
    }
    
    @Test func unsupportedClass() {
        let json = """
        {
            "version": "2.0",
            "updated": "2024-11-20T08:00:00Z",
            "class": "invalid",
            "id": [],
            "size": [],
            "value": [],
            "dimension": {}
        }
        """
        #expect(throws: DecodeError.unsupportedClass) {
            try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        }
    }
    
    @Test func unsupportedLink() {
        let json = """
        {
            "class" : "collection",
            "href" : "https://json-stat.org/samples/collection.json",
            "label" : "JSON-stat Dataset Sample Collection",
            "link" : {
              "item" : [
                {
                  "class": "invalid"
                }
              ]
            },
            "updated": "2024-11-20T08:00:00Z",
            "version": "2.0"
        }
        """
        #expect(throws: DecodeError.unsupportedLink) {
            try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        }
    }

    @Test func IntDynamicCodingKeys() {
        #expect(DynamicCodingKeys(intValue: 8) == nil)
    }
}
