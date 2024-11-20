//
//  TestHelpers.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 18/11/2024.
//

import Foundation

func loadSampleFile(named fileName: String) throws -> String {
    let filePath = Bundle.module.path(forResource: fileName, ofType: "json")!
    return try String(contentsOf: URL(filePath: filePath)).trimmingCharacters(in: .whitespacesAndNewlines)
}
