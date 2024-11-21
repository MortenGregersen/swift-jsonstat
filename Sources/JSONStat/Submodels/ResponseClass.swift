//
//  ResponseClass.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public indirect enum ResponseClass: Codable, Equatable {
    case dataset(JSONStatV2.Dataset)
    case dimension(Dimension)
    case collection(Collection)
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONStatV2.CodingKeys.self)
        let responseClass = try container.decode(String.self, forKey: .class)
        switch responseClass {
        case "dataset": self = try .dataset(JSONStatV2.Dataset(from: decoder))
        case "dimension": self = try .dimension(Dimension(from: decoder))
        case "collection": self = try .collection(Collection(from: decoder))
        default: throw DecodeError.unsupportedClass
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: JSONStatV2.CodingKeys.self)
        switch self {
        case .dataset(let dataset):
            try keyedContainer.encode("dataset", forKey: .class)
            try dataset.encode(to: encoder)
        case .dimension(let dimension):
            try keyedContainer.encode("dimension", forKey: .class)
            try dimension.encode(to: encoder)
        case .collection(let collection):
            try keyedContainer.encode("collection", forKey: .class)
            try collection.encode(to: encoder)
        }
    }
        
    public struct Collection: Codable, Equatable {
        public var updated: Date?
        public var href: URL?
        public var label: String?
        public var links: [String: [Link]]?
            
        private enum CodingKeys: String, CodingKey {
            case updated
            case href
            case label
            case links = "link"
        }
    }
}
