//
//  JSONStatV2.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public struct JSONStatV2: Codable, Equatable {
    public var version: String
    public var label: String?
    public var responseClass: ResponseClass

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        responseClass = try ResponseClass(from: decoder)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(label, forKey: .label)
        try responseClass.encode(to: encoder)
    }

    internal enum CodingKeys: CodingKey {
        case version
        case label
        case `class`
    }

    public struct Dataset: Codable, Equatable {
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
