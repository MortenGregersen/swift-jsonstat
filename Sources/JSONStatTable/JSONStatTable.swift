//
//  JSONStatTable.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 18/11/2024.
//

import Foundation
import JSONStat
import struct JSONStat.Dimension

public enum JSONStatTableError: Error {
    case dimensionMismatch // The number of dimensions doesn't match the priority list
    case usingReservedColumnId // The column ID is reserved and can't be used
    case missingLabel // A label is missing for a category
}

public struct JSONStatTable {
    public let header: Header
    public let rows: [Row]

    public init(dataset: JSONStatV1.Dataset) throws {
        try self.init(dimensions: dataset.dimensionsInfo.dimensions, ids: dataset.dimensionsInfo.id, values: dataset.values, status: dataset.status)
    }

    public init(dataset: JSONStatV2.Dataset) throws {
        try self.init(dimensions: dataset.dimensions, ids: dataset.id, values: dataset.values, status: dataset.status)
    }

    private init(dimensions: [String: Dimension], ids: [String], values: Values, status: Status?) throws {
        let sortedDimensions = ids.compactMap { dimensions[$0] }
        guard sortedDimensions.count == ids.count else {
            throw JSONStatTableError.dimensionMismatch
        }
        header = try .init(
            dimensionIdLabels: dimensions.mapValues(\.label),
            dimensionIndicesLabels: ids.map { dimensions[$0]?.label ?? "" },
            hasStatus: status != nil
        )
        rows = try Self.createRows(from: sortedDimensions, values: values, status: status)
    }

    private static func createRows(from sortedDimensions: [Dimension], values: Values, status: Status?) throws -> [Row] {
        var rows = [Row]()
        let combinations = try generateCombinations(dimensions: sortedDimensions)

        let stringValues: [String: String?]
        switch values {
        case .numbers(let values):
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            formatter.decimalSeparator = "."
            let numberValues: [String: Double?] = switch values {
            case .array(let values):
                values.enumerated().reduce(into: [:]) { result, tuple in
                    result["\(tuple.offset)"] = tuple.element
                }
            case .dictionary(let values):
                values
            }
            stringValues = numberValues.mapValues { value in
                formatter.string(for: value) ?? ""
            }
        case .strings(let values):
            switch values {
            case .array(let values):
                stringValues = values.enumerated().reduce(into: [:]) { result, tuple in
                    result["\(tuple.offset)"] = tuple.element
                }
            case .dictionary(let values):
                stringValues = values
            }
        }

        for (index, combination) in combinations.enumerated() {
            let value = stringValues.first(where: { $0.key == "\(index)" })?.value ?? ""
            var statusString: String? = nil
            if let status {
                statusString = switch status {
                case .array(let status):
                    if status.count == 1 {
                        status[0] ?? ""
                    } else if status.count >= index {
                        status[index] ?? ""
                    } else {
                        ""
                    }
                case .dictionary(let status):
                    status.first(where: { $0.key == "\(index)" })?.value ?? ""
                case .string(let status):
                    status
                }
            }
            let dimensionIdLabels = combination.reduce(into: [:]) { partialResult, indexAndLabel in
                partialResult[indexAndLabel.index] = indexAndLabel.label
            }
            try rows.append(Row(value: value, cellByColumnId: dimensionIdLabels, cellByIndex: combination.map(\.label), status: statusString))
        }
        return rows
    }

    private static func generateCombinations(dimensions: [Dimension], current: [(String, String)] = []) throws -> [[(index: String, label: String)]] {
        guard let dimension = dimensions.first else { return [current] }
        var results = [[(index: String, label: String)]]()
        var remainingDimensions = dimensions
        remainingDimensions.removeAll(where: { $0 == dimension })
        let categoryIndexLabels: [(index: String, label: String)]
        if let indices = dimension.category.indices {
            switch indices {
            case .dictionary(let indicesDict):
                let sortedLabelIds = indicesDict
                    .sorted(using: KeyPathComparator(\.value))
                    .map(\.key)
                categoryIndexLabels = sortedLabelIds.compactMap {
                    let label = dimension.category.labels?[$0] ?? $0
                    return ($0, label)
                }
                guard categoryIndexLabels.count == sortedLabelIds.count else {
                    throw JSONStatTableError.missingLabel
                }
            case .array(let indicesArray):
                categoryIndexLabels = indicesArray.compactMap { $0 }.compactMap {
                    let label = dimension.category.labels?[$0] ?? $0
                    return ($0, label)
                }
                guard categoryIndexLabels.count == indicesArray.count else {
                    throw JSONStatTableError.missingLabel
                }
            }
        } else if let labels = dimension.category.labels {
            categoryIndexLabels = labels.map { ($0.key, $0.value) }
        } else {
            categoryIndexLabels = [(dimension.label, dimension.label)]
        }
        for indexAndLabel in categoryIndexLabels {
            var newCurrent = current
            newCurrent.append(indexAndLabel)
            try results.append(contentsOf: generateCombinations(dimensions: remainingDimensions, current: newCurrent))
        }
        return results
    }

    public struct Header: Sequence {
        private let dimensionIdLabels: [String: String]
        private let dimensionIndicesLabels: [String]

        init(dimensionIdLabels: [String: String], dimensionIndicesLabels: [String], hasStatus: Bool) throws {
            var dimensionIdLabels = dimensionIdLabels
            var dimensionIndicesLabels = dimensionIndicesLabels
            if hasStatus {
                try dimensionIdLabels.merge(["status": "status"], uniquingKeysWith: { _, _ in throw JSONStatTableError.usingReservedColumnId })
                dimensionIndicesLabels.append("status")
            }
            try dimensionIdLabels.merge(["value": "value"], uniquingKeysWith: { _, _ in throw JSONStatTableError.usingReservedColumnId })
            dimensionIndicesLabels.append("value")
            self.dimensionIdLabels = dimensionIdLabels
            self.dimensionIndicesLabels = dimensionIndicesLabels
        }

        public subscript(key: String) -> String? {
            dimensionIdLabels[key]
        }

        public subscript(index: Int) -> String? {
            dimensionIndicesLabels[index]
        }

        public func makeIterator() -> IndexingIterator<[String]> {
            dimensionIndicesLabels.makeIterator()
        }
    }

    public struct Row: Sequence {
        private let cellByColumnId: [String: String]
        private let cellByIndex: [String]

        init(value: String, cellByColumnId: [String: String], cellByIndex: [String], status: String? = nil) throws {
            var cellByColumnId = cellByColumnId
            var cellByIndex = cellByIndex
            if let status {
                try cellByColumnId.merge(["status": status], uniquingKeysWith: { _, _ in throw JSONStatTableError.usingReservedColumnId })
                cellByIndex.append(status)
            }
            try cellByColumnId.merge(["value": value], uniquingKeysWith: { _, _ in throw JSONStatTableError.usingReservedColumnId })
            cellByIndex.append(value)
            self.cellByColumnId = cellByColumnId
            self.cellByIndex = cellByIndex
        }

        public subscript(key: String) -> String? {
            cellByColumnId[key]
        }

        public subscript(index: Int) -> String? {
            cellByIndex[index]
        }

        public func makeIterator() -> IndexingIterator<[String]> {
            cellByIndex.makeIterator()
        }
    }
}
