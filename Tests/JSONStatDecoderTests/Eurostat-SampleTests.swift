import Foundation
import SwiftJSONStat
import Testing

// Samples from https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/api-statistics

struct EurostatSampleTests {
    @Test func DecodeNama10gdp() throws {
        let json = try loadExampleJSON(named: "nama_10_gdp")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 5)
    }
    
    @Test func DecodeDemoGind() throws {
        let json = try loadExampleJSON(named: "demo_gind")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 4)
    }

    private func loadExampleJSON(named fileName: String) throws -> String {
        let filePath = Bundle.module.path(forResource: "Eurostat-Samples/\(fileName)", ofType: "json")!
        return try String(contentsOf: URL(filePath: filePath))
    }
}
