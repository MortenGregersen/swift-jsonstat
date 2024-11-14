import Foundation
import SwiftJSONStat
import Testing

// Samples from https://json-stat.org/format/

struct JSOrgSampleTests {
    @Test func DecodeCanada() throws {
        let json = try loadExampleJSON(named: "canada")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 5)
    }

    @Test func DecodeCollection() throws {
        let json = try loadExampleJSON(named: "collection")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .collection(let collection) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(collection.links?["item"]?.count == 8)
    }

    @Test func DecodeDenmark() throws {
        let json = try loadExampleJSON(named: "denmark")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        print(jsonStat)
        guard case .v1(let jsonStatV1) = jsonStat, case .multipleDatasets(let datasets) = jsonStatV1 else {
            fatalError()
        }
        #expect(datasets.values.first?.dimensionsInfo.dimensions.count == 3)
    }

    @Test func DecodeGalicia() throws {
        let json = try loadExampleJSON(named: "galicia")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 6)
    }

    @Test func DecodeHierarchy() throws {
        let json = try loadExampleJSON(named: "hierarchy")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 1)
    }

    @Test func DecodeOECD_Canada() throws {
        let json = try loadExampleJSON(named: "oecd-canada")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat, case .multipleDatasets(let datasets) = jsonStatV1 else {
            fatalError()
        }
        #expect(datasets["oecd"]?.dimensionsInfo.dimensions.count == 3)
    }

    @Test func DecodeOECD_Canada_COL() throws {
        let json = try loadExampleJSON(named: "oecd-canada-col")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .collection(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.links?["item"]?.count == 2)
    }

    @Test func DecodeOrder() throws {
        let json = try loadExampleJSON(named: "order")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 3)
        guard case .strings(let stringValues) = dataset.values,
              case .array(let values) = stringValues else {
            fatalError()
        }
        #expect(values.count == 24)
    }

    @Test func DecodeUS_GSP() throws {
        let json = try loadExampleJSON(named: "us-gsp")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 3)
    }

    @Test func DecodeUS_Labor() throws {
        let json = try loadExampleJSON(named: "us-labor")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 3)
    }

    @Test func DecodeUS_UNR() throws {
        let json = try loadExampleJSON(named: "us-unr")
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat, case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.dimensions.count == 3)
    }

    private func loadExampleJSON(named fileName: String) throws -> String {
        let filePath = Bundle.module.path(forResource: "JSOrg-Samples/\(fileName)", ofType: "json")!
        return try String(contentsOf: URL(filePath: filePath))
    }
}
