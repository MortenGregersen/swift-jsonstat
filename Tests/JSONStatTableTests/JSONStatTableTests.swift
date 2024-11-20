//
//  JSONStatTableTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 18/11/2024.
//

import Foundation
import JSONStat
import JSONStatTable
import Testing

struct JSONStatTableTests {
    @Test func createTable() async throws {
        let jsonString = try loadSampleFile(named: "JSONStatOrg/order")
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: jsonString.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat,
              case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError("JSONStat is not v2")
        }
        let table = try JSONStatTable(dataset: dataset)
        #expect(table.header["A"] == "A: 3-categories dimension")
        #expect(table.header["B"] == "B: 2-categories dimension")
        #expect(table.header["C"] == "C: 4-categories dimension")
        #expect(table.header["value"] == "value")
    }
}
