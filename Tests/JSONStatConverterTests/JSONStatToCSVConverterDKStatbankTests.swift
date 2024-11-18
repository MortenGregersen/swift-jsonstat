//
//  JSONStatToCSVConverterDKStatbankTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Testing

struct JSONStatToCSVConverterDKStatbankTests {
    @Test func convertHISB3ToCSV() async throws {
        try convertToCSVAndCompareToSnapshot(named: "DKStatbank/HISB3")
    }
}
