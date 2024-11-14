//
//  ResponseClass.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public indirect enum ResponseClass: Codable {
    case dataset(Dataset)
    case dimension(Dimension)
    case collection(Collection)
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONStatV2.CodingKeys.self)
        let responseClass = try container.decode(String.self, forKey: .class)
        switch responseClass {
        case "dataset": self = try .dataset(Dataset(from: decoder))
        case "dimension": self = try .dimension(Dimension(from: decoder))
        case "collection": self = try .collection(Collection(from: decoder))
        default: throw DecodeError.unsupportedClass
        }
    }
        
    public struct Collection: Codable {
        public var updated: Date?
        public var href: URL?
        public var links: [String: [Link]]?
            
        private enum CodingKeys: String, CodingKey {
            case updated
            case href
            case links = "link"
        }
    }
        
    public struct Dataset: Codable {
        public var id: [String]
        public var size: [Int]
        public var roles: Roles?
        public var values: Values
        public var status: Status?
        public var dimensions: [String: Dimension]
        public var updated: Date?
        public var source: String?
        public var href: URL?
        public var links: [String: [Link]]?
        public var notes: [String]?
            
        private enum CodingKeys: String, CodingKey {
            case id
            case size
            case roles = "role"
            case values = "value"
            case status
            case dimensions = "dimension"
            case updated
            case source
            case href
            case links = "link"
            case notes = "note"
        }
    }
}
