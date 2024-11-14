//
//  JSONStatV1.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public enum JSONStatV1: Decodable {
    case singleDataset(Dataset)
    case multipleDatasets([String: Dataset])

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        if container.contains(.init(stringValue: "value")!) {
            self = try .singleDataset(Dataset(from: decoder))
        } else {
            let container = try decoder.singleValueContainer()
            self = try .multipleDatasets(container.decode([String: Dataset].self))
        }
    }

    enum CodingKeys: CodingKey {
        case value
    }

    public struct Dataset: Decodable {
        public var dimensionsInfo: DimensionsInfo
        public var values: Values
        public var status: Status?
        public var updated: Date?
        public var source: String?
        public var notes: [String]?

        private enum CodingKeys: String, CodingKey {
            case dimensionsInfo = "dimension"
            case values = "value"
            case status
            case updated
            case source
            case notes = "note"
        }

        public struct DimensionsInfo: Decodable {
            public var id: [String]
            public var size: [Int]
            public var roles: Roles?
            public var dimensions: [String: Dimension]

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
                id = try container.decode([String].self, forKey: CodingKeys.id.dynamicKey)
                size = try container.decode([Int].self, forKey: CodingKeys.size.dynamicKey)
                roles = try container.decodeIfPresent(Roles.self, forKey: CodingKeys.roles.dynamicKey)
                dimensions = try container.allKeys
                    .filter { key in !CodingKeys.allCases.map(\.dynamicKey).contains(where: { $0 == key }) }
                    .reduce(into: [String: Dimension]()) { result, dimensionKey in
                        result[dimensionKey.stringValue] = try container.decode(Dimension.self, forKey: dimensionKey)
                    }
            }

            private enum CodingKeys: String, CodingKey, CaseIterable {
                case id
                case size
                case roles = "role"

                var dynamicKey: DynamicCodingKeys {
                    .init(stringValue: rawValue)!
                }
            }
        }
    }
}
