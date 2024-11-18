//
//  JSONStatToCSVConverter.swift.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation
import JSONStatDecoder

public enum ConvertError: Error {
    case dimensionMismatch // The number of dimensions doesn't match the priority list
    case missingLabel // A label is missing for a category
}

public class JSONStatToCSVConverter {
    public init() {}

    public func convertToCSV(jsonStatDataset: JSONStatV1.Dataset) throws -> String {
        let dimensionsInfo = jsonStatDataset.dimensionsInfo
        let sortedDimensions = dimensionsInfo.id.compactMap { dimensionsInfo.dimensions[$0] }
        guard sortedDimensions.count == dimensionsInfo.id.count else {
            throw ConvertError.dimensionMismatch
        }
        return try convertToCSV(sortedDimensions: sortedDimensions, values: jsonStatDataset.values, status: jsonStatDataset.status)
    }

    public func convertToCSV(jsonStatDataset: JSONStatV2.Dataset) throws -> String {
        let sortedDimensions = jsonStatDataset.id.compactMap { jsonStatDataset.dimensions[$0] }
        guard sortedDimensions.count == jsonStatDataset.id.count else {
            throw ConvertError.dimensionMismatch
        }
        return try convertToCSV(sortedDimensions: sortedDimensions, values: jsonStatDataset.values, status: jsonStatDataset.status)
    }

    private func convertToCSV(sortedDimensions: [JSONStatDecoder.Dimension], values: Values, status: Status?) throws -> String {
        var header = sortedDimensions.map(\.label).map(\.csvEscaped).joined(separator: ",")
        if status != nil {
            header += ",status"
        }
        var lines = [header + ",value"]
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
            var line = combination
                .map(\.csvEscaped)
                .joined(separator: ",")
            if let status {
                let statusString: String = switch status {
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
                line += ",\(statusString.csvEscaped)"
            }
            line += ",\(value.csvEscaped)"
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }

    private func generateCombinations(dimensions: [JSONStatDecoder.Dimension], current: [String] = []) throws -> [[String]] {
        guard let dimension = dimensions.first else { return [current] }
        var results = [[String]]()
        var remainingDimensions = dimensions
        remainingDimensions.removeAll(where: { $0 == dimension })
        let categoryLabels: [String]
        if let indices = dimension.category.indices {
            switch indices {
            case .dictionary(let indicesDict):
                let sortedLabelIds = indicesDict
                    .sorted(using: KeyPathComparator(\.value))
                    .map(\.key)
                categoryLabels = sortedLabelIds.compactMap {
                    dimension.category.labels?[$0] ?? $0
                }
                guard categoryLabels.count == sortedLabelIds.count else {
                    throw ConvertError.missingLabel
                }
            case .array(let indicesArray):
                categoryLabels = indicesArray.compactMap { $0 }.compactMap {
                    dimension.category.labels?[$0] ?? $0
                }
                guard categoryLabels.count == indicesArray.count else {
                    throw ConvertError.missingLabel
                }
            }
        } else if let singleLabel = dimension.category.labels?.first {
            categoryLabels = [singleLabel.value]
        } else {
            throw ConvertError.missingLabel
        }
        for label in categoryLabels {
            var newCurrent = current
            newCurrent.append(label)
            try results.append(contentsOf: generateCombinations(dimensions: remainingDimensions, current: newCurrent))
        }
        return results
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
