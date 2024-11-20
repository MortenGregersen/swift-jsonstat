//
//  TestHelpers.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 15/11/2024.
//

import Foundation
import JSONStatConverter
import JSONStat
import Testing

func loadSampleFile(named fileName: String, fileExtension: FileExtension) throws -> String {
    let filePath = Bundle.module.path(forResource: fileName, ofType: fileExtension.rawValue)!
    return try String(contentsOf: URL(filePath: filePath)).trimmingCharacters(in: .whitespacesAndNewlines)
}

enum FileExtension: String {
    case json
    case csv
}

func convertToCSVAndCompareToSnapshot(named fileName: String) throws {
    let json = try loadSampleFile(named: fileName, fileExtension: .json)
    let decoder = JSONStat.decoder
    let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
    switch jsonStat {
    case .v1(let jsonStatV1):
        try convertToCSVAndCompareToSnapshot(jsonStatV1: jsonStatV1, fileName: fileName)
    case .v2(let jsonStatV2):
        try convertToCSVAndCompareToSnapshot(jsonStatV2: jsonStatV2, fileName: fileName)
    }
}

func convertToCSVAndCompareToSnapshot(jsonStatV1: JSONStatV1, fileName: String) throws {
    switch jsonStatV1 {
    case .singleDataset(let dataset):
        try convertToCSVAndCompareToSnapshot(dataset: dataset, csvFileName: fileName)
    case .multipleDatasets(let datasets):
        if datasets.count == 1, let dataset = datasets.values.first {
            try convertToCSVAndCompareToSnapshot(dataset: dataset, csvFileName: fileName)
        } else {
            for (index, dataset) in datasets.sorted(using: KeyPathComparator(\.key)).map(\.value).enumerated() {
                try convertToCSVAndCompareToSnapshot(dataset: dataset, csvFileName: fileName + "-\(index + 1)")
            }
        }
    }
}

func convertToCSVAndCompareToSnapshot(dataset: JSONStatV1.Dataset, csvFileName: String) throws {
    let csv = try loadSampleFile(named: csvFileName, fileExtension: .csv)
    let converter = JSONStatToCSVConverter()
    let convertedCSV = try converter.convertToCSV(jsonStatDataset: dataset)
    #expect(convertedCSV == csv)
}

func convertToCSVAndCompareToSnapshot(jsonStatV2: JSONStatV2, fileName: String) throws {
    switch jsonStatV2.responseClass {
    case .collection(let collection):
        try collection.links?.forEach { (_: String, value: [Link]) in
            for (index, link) in value.enumerated() {
                guard case .dataset(let dataset) = link else {
                    fatalError()
                }
                try convertToCSVAndCompareToSnapshot(dataset: dataset, csvFileName: fileName + "-\(index + 1)")
            }
        }
    case .dataset(let dataset):
        try convertToCSVAndCompareToSnapshot(dataset: dataset, csvFileName: fileName)
    default:
        fatalError()
    }
}

func convertToCSVAndCompareToSnapshot(dataset: JSONStatV2.Dataset, csvFileName: String) throws {
    let csv = try loadSampleFile(named: csvFileName, fileExtension: .csv)
    let converter = JSONStatToCSVConverter()
    let convertedCSV = try converter.convertToCSV(jsonStatDataset: dataset)
    #expect(convertedCSV == csv)
}
