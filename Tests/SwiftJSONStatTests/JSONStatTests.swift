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

    func testDecodeCollection() throws {
        let json = try loadExampleJSON(named: "collection")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .collection(let collection) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(collection.links?["item"]?.count, 8)
    }

    func testDecodeDenmark() throws {
        let json = try loadExampleJSON(named: "denmark")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        print(jsonStat)
        guard case .v1(let jsonStatV1) = jsonStat, case .multipleDatasets(let datasets) = jsonStatV1 else {
            XCTFail(); return
        }
        XCTAssertEqual(datasets.values.first?.dimensionsInfo.dimensions.count, 3)
    }

    func testDecodeGalicia() throws {
        let json = try loadExampleJSON(named: "galicia")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 6)
    }

    func testDecodeHierarchy() throws {
        let json = try loadExampleJSON(named: "hierarchy")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 1)
    }
    
    func testDecodeOECD_Canada() throws {
        let json = try loadExampleJSON(named: "oecd-canada")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat, case .multipleDatasets(let datasets) = jsonStatV1 else {
            XCTFail(); return
        }
        XCTAssertEqual(datasets["oecd"]?.dimensionsInfo.dimensions.count, 3)
    }
    
    func testDecodeOECD_Canada_COL() throws {
        let json = try loadExampleJSON(named: "oecd-canada-col")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .collection(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.links?["item"]?.count, 2)
    }

    func testDecodeOrder() throws {
        let json = try loadExampleJSON(named: "order")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 3)
        guard case .strings(let stringValues) = dataset.values,
              case .array(let values) = stringValues else {
            throw JSONStat.DecodeError.unsupportedValues
        }
        XCTAssertEqual(values.count, 24)
    }
    
    func testDecodeUS_GSP() throws {
        let json = try loadExampleJSON(named: "us-gsp")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 3)
    }
    
    func testDecodeUS_Labor() throws {
        let json = try loadExampleJSON(named: "us-labor")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 3)
    }
    
    func testDecodeUS_UNR() throws {
        let json = try loadExampleJSON(named: "us-unr")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            XCTFail(); return
        }
        XCTAssertEqual(dataset.dimensions.count, 3)
    }

    private func loadExampleJSON(named fileName: String) throws -> String {
        let filePath = Bundle.module.path(forResource: "Examples/\(fileName)", ofType: "json")!
        return try String(contentsOf: URL(filePath: filePath))
    }
}
