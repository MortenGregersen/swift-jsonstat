//
//  JSONStatToCSVConverterEurostatTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Testing

struct JSONStatToCSVConverterEurostatTests {
    @Test func convertDemo_GindToCSV() async throws {
        try convertToCSVAndCompareToSnapshot(named: "Eurostat/demo_gind")
    }
    
    @Test func convertNama_10_GDPToCSV() async throws {
        try convertToCSVAndCompareToSnapshot(named: "Eurostat/nama_10_gdp")
    }
}
