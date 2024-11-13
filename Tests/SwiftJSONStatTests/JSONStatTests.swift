@testable import SwiftJSONStat
import XCTest

final class JSONStatTests: XCTestCase {
    func testDecodeCanada() throws {
        let json = try loadExampleJSON(named: "canada")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 5)
    }

    func testDecodeDenmark() throws {
        let json = try loadExampleJSON(named: "denmark")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat else {
            XCTFail(); return
        }
        XCTAssertEqual(jsonStatV1.dataset.dimensionsInfo.dimensions.count, 3)
    }

    private func loadExampleJSON(named fileName: String) throws -> String {
        let filePath = Bundle.module.path(forResource: "Examples/\(fileName)", ofType: "json")!
        return try String(contentsOf: URL(filePath: filePath))
    }
}
