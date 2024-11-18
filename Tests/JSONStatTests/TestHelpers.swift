//
//  File.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 18/11/2024.
//

import Foundation
import JSONStatDecoder
import Testing

func loadSampleFile(named fileName: String) throws -> String {
    let filePath = Bundle.module.path(forResource: fileName, ofType: "json")!
    return try String(contentsOf: URL(filePath: filePath)).trimmingCharacters(in: .whitespacesAndNewlines)
}

func decodeAndEncodeSample(named fileName: String) throws {
    let jsonString = try loadSampleFile(named: fileName)
    let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: jsonString.data(using: .utf8)!)
    let encodedJSON = try JSONStat.encoder.encode(jsonStat)
    let encodedJSONString = String(data: encodedJSON, encoding: .utf8)
    let jsonSnapshotString = try loadSampleFile(named: fileName + "-snapshot")
    #expect(encodedJSONString == jsonSnapshotString)
}
