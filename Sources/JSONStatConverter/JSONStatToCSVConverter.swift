//
//  JSONStatToCSVConverter.swift.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation
import JSONStat
import struct JSONStat.Dimension
import JSONStatTable

public class JSONStatToCSVConverter {
    public init() {}

    public func convertToCSV(jsonStatDataset: JSONStatV1.Dataset) throws -> String {
        try convertToCSV(table: JSONStatTable(dataset: jsonStatDataset))
    }

    public func convertToCSV(jsonStatDataset: JSONStatV2.Dataset) throws -> String {
        try convertToCSV(table: JSONStatTable(dataset: jsonStatDataset))
    }

    private func convertToCSV(table: JSONStatTable) throws -> String {
        let header = table.header.map(\.csvEscaped).joined(separator: ",")
        let rows: [String] = table.rows.map { (row: JSONStatTable.Row) -> String in
            row.map(\.csvEscaped).joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }
}

private extension String {
    var csvEscaped: String {
        if contains(",") {
            "\"\(self)\""
        } else {
            self
        }
    }
}
