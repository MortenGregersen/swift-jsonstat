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
    @Test func createTableWithV2() async throws {
        let jsonString = try loadSampleFile(named: "JSONStatOrg/canada")
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: jsonString.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat,
              case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError("JSONStat is not v2")
        }
        let table = try JSONStatTable(dataset: dataset)
        #expect(table.header["country"] == "country")
        #expect(table.header[0] == "country")
        #expect(table.header["year"] == "year")
        #expect(table.header[1] == "year")
        #expect(table.header["age"] == "age group")
        #expect(table.header[2] == "age group")
        #expect(table.header["concept"] == "concepts")
        #expect(table.header[3] == "concepts")
        #expect(table.header["sex"] == "sex")
        #expect(table.header[4] == "sex")
        #expect(table.header["status"] == "status")
        #expect(table.header[5] == "status")
        #expect(table.header["value"] == "value")
        #expect(table.header[6] == "value")
        let row = table.rows[49]
        #expect(row["country"]?.id == "CA")
        #expect(row["country"]?.label == "Canada")
        #expect(row[1]?.label == "2012")
        #expect(row["age"]?.label == "35 to 39")
        #expect(row[3]?.label == "population")
        #expect(row[4]?.label == "male")
        #expect(row["status"]?.label == "a")
        #expect(row["value"]?.label == "1155.2")
    }

    @Test func createTableWithV1() async throws {
        let jsonString = try loadSampleFile(named: "DKStatbank/HISB3")
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: jsonString.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat,
              jsonStatV1.datasets.count == 1,
              let dataset = jsonStatV1.datasets.values.first else {
            fatalError("JSONStat is not v1")
        }
        let table = try JSONStatTable(dataset: dataset)
        #expect(table.header[0] == "bevægelsesart")
        #expect(table.header[1] == "Indhold")
        #expect(table.header[2] == "tid")
        #expect(table.header["value"] == "value")
    }

    @Test func queryTableRows() async throws {
        let jsonString = try loadSampleFile(named: "DKStatbank/HISB3")
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: jsonString.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat,
              jsonStatV1.datasets.count == 1,
              let dataset = jsonStatV1.datasets.values.first else {
            fatalError("JSONStat is not v1")
        }
        let table = try JSONStatTable(dataset: dataset)
        guard let row = table.getRow(withQuery: ["BEVÆGELSE": "M+K", "Tid": "2023"]) else {
            fatalError("Row not found")
        }
        #expect(row.value == "5933")
    }
}
