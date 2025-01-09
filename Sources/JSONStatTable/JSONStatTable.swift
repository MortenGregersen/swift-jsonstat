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

    public func getRow(withQuery query: [String: String]) -> Row? {
        rows.first { row in
            query.allSatisfy { key, value in
                row[key]?.id == value
            }
        }
    }
    
    private init(dimensions: [String: Dimension], ids: [String], values: Values, status: Status?) throws {
        let sortedDimensions = ids.compactMap { (id: String) -> (String, Dimension)? in
            guard let dimension = dimensions[id] else { return nil }
            return (dimensionId: id, dimension: dimension)
        }
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

    private static func createRows(from sortedDimensions: [(String, Dimension)], values: Values, status: Status?) throws -> [Row] {
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
            var statusString: String?
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
            let cellByColumnId = combination.reduce(into: [:]) { partialResult, indexAndLabel in
                partialResult[indexAndLabel.dimensionId] = (id: indexAndLabel.index, label: indexAndLabel.label)
            }
            let cellByIndex = combination.map { (id: $0.index, label: $0.label) }
            try rows.append(.init(value: value, cellByColumnId: cellByColumnId, cellByIndex: cellByIndex, status: statusString))
        }
        return rows
    }

    private static func generateCombinations(dimensions: [(dimensionId: String, dimension: Dimension)], current: [(String, String, String)] = []) throws -> [[(dimensionId: String, index: String, label: String)]] {
        guard let (dimensionId, dimension) = dimensions.first else { return [current] }
        var results = [[(dimensionId: String, index: String, label: String)]]()
        var remainingDimensions = dimensions
        remainingDimensions.removeAll(where: { $0.dimensionId == dimensionId })
        let categoryIndexLabels: [(dimensionId: String, index: String, label: String)]
        if let indices = dimension.category.indices {
            switch indices {
            case .dictionary(let indicesDict):
                let sortedLabelIds = indicesDict
                    .sorted(using: KeyPathComparator(\.value))
                    .map(\.key)
                categoryIndexLabels = sortedLabelIds.compactMap {
                    let label = dimension.category.labels?[$0] ?? $0
                    return (dimensionId, $0, label)
                }
                guard categoryIndexLabels.count == sortedLabelIds.count else {
                    throw JSONStatTableError.missingLabel
                }
            case .array(let indicesArray):
                categoryIndexLabels = indicesArray.compactMap { $0 }.compactMap {
                    let label = dimension.category.labels?[$0] ?? $0
                    return (dimensionId, $0, label)
                }
                guard categoryIndexLabels.count == indicesArray.count else {
                    throw JSONStatTableError.missingLabel
                }
            }
        } else if let labels = dimension.category.labels {
            categoryIndexLabels = labels.map { (dimensionId, $0.key, $0.value) }
        } else {
            categoryIndexLabels = [(dimensionId, dimension.label, dimension.label)]
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
        public let value: String
        private let cellByColumnId: [String: (id: String, label: String)]
        private let cellByIndex: [(id: String, label: String)]

        init(value: String, cellByColumnId: [String: (id: String, label: String)], cellByIndex: [(id: String, label: String)], status: String? = nil) throws {
            var cellByColumnId = cellByColumnId
            var cellByIndex = cellByIndex
            if let status {
                let status = (id: "status", label: status)
                try cellByColumnId.merge(["status": status], uniquingKeysWith: { _, _ in throw JSONStatTableError.usingReservedColumnId })
                cellByIndex.append(status)
            }
            self.value = value
            let value = (id: "value", label: value)
            try cellByColumnId.merge(["value": value], uniquingKeysWith: { _, _ in throw JSONStatTableError.usingReservedColumnId })
            cellByIndex.append(value)
            self.cellByColumnId = cellByColumnId
            self.cellByIndex = cellByIndex
        }

        public subscript(key: String) -> (id: String, label: String)? {
            cellByColumnId[key]
        }

        public subscript(index: Int) -> (id: String, label: String)? {
            cellByIndex[index]
        }

        public func makeIterator() -> IndexingIterator<[(id: String, label: String)]> {
            cellByIndex.makeIterator()
        }
    }
}
