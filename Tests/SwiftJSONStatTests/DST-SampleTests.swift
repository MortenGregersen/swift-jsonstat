import Foundation
import SwiftJSONStat
import Testing

// Samples from https://api.statbank.dk/console#data

struct DSTSampleTests {
    @Test func DecodeHISB3() throws {
        let json = try loadExampleJSON(named: "HISB3")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat,
              case .multipleDatasets(let datasets) = jsonStatV1,
              let dataset = datasets.values.first,
              case .numbers(let numberValues) = dataset.values,
              case .array(let values) = numberValues else {
            fatalError()
        }
        #expect(dataset.dimensionsInfo.dimensions.count == 3)
        #expect(values == [5961])
    }

    private func loadExampleJSON(named fileName: String) throws -> String {
        let filePath = Bundle.module.path(forResource: "DST-Samples/\(fileName)", ofType: "json")!
        return try String(contentsOf: URL(filePath: filePath))
    }
}
