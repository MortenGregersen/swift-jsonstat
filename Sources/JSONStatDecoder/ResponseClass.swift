//
//  ResponseClass.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public indirect enum ResponseClass: Decodable, Equatable {
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
        
    public struct Collection: Decodable, Equatable {
        public var updated: Date?
        public var href: URL?
        public var links: [String: [Link]]?
            
        private enum CodingKeys: String, CodingKey {
            case updated
            case href
            case links = "link"
        }
    }
}
