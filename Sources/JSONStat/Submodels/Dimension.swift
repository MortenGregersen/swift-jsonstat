//
//  Dimension.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public struct Dimension: Codable, Equatable, Sendable {
    public var category: Dimension.Category
    public var label: String
    public var href: URL?
    public var links: [String: [Link]]?
    public var notes: [String]?
    public var `extension`: JSON?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try container.decode(Dimension.Category.self, forKey: .category)
        self.label = try container.decode(String.self, forKey: .label)
        self.href = try container.decodeIfPresent(URL.self, forKey: .href)
        self.links = try container.decodeIfPresent([String: [Link]].self, forKey: .links)
        self.notes = try container.decodeIfPresent([String].self, forKey: .notes)
        self.extension = try container.decodeIfPresent(JSON.self, forKey: .extension)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.category, forKey: .category)
        try container.encode(self.label, forKey: .label)
        try container.encodeIfPresent(self.href, forKey: .href)
        try container.encodeIfPresent(self.links, forKey: .links)
        try container.encodeIfPresent(self.notes, forKey: .notes)
        try container.encodeIfPresent(self.extension, forKey: .extension)
    }

    private enum CodingKeys: String, CodingKey {
        case category
        case label
        case responseClass = "class"
        case href
        case links = "link"
        case notes = "note"
        case `extension`
    }

    public struct Category: Codable, Equatable, Sendable {
        public var indices: Indices?
        public var labels: [String: String]?
        public var children: [String: [String]]?
        public var coordinates: [String: [Double]]?
        public var units: [String: Unit]?
        public var notes: [String: [String]]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.indices = try container.decodeIfPresent(Indices.self, forKey: .indices)
            self.labels = try container.decodeIfPresent([String: String].self, forKey: .labels)
            self.children = try container.decodeIfPresent([String: [String]].self, forKey: .children)
            self.coordinates = try container.decodeIfPresent([String: [Double]].self, forKey: .coordinates)
            self.units = try container.decodeIfPresent([String: Unit].self, forKey: .units)
            self.notes = try container.decodeIfPresent([String: [String]].self, forKey: .notes)
        }

        private enum CodingKeys: String, CodingKey {
            case indices = "index"
            case labels = "label"
            case children = "child"
            case coordinates
            case units = "unit"
            case notes = "note"
        }

        public struct Unit: Codable, Equatable, Sendable {
            // Closed properties
            public var decimals: Int?
            public var label: String?
            public var symbol: String?
            public var position: String?
            // Open properties
            public var base: String?
            public var type: String?
            public var multiplier: Double?
            public var adjustment: String?
        }
    }
}
