//
//  Dimension.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public struct Dimension: Decodable, Equatable {
    public var category: Dimension.Category
    public var label: String
    public var responseClass: ResponseClass?
    public var href: URL?
    public var links: [String: [Link]]?
    public var notes: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = try container.decode(Dimension.Category.self, forKey: .category)
        label = try container.decode(String.self, forKey: .label)
        responseClass = try container.decodeIfPresent(ResponseClass.self, forKey: .responseClass)
        href = try container.decodeIfPresent(URL.self, forKey: .href)
        links = try container.decodeIfPresent([String: [Link]].self, forKey: .links)
        notes = try container.decodeIfPresent([String].self, forKey: .notes)
    }

    private enum CodingKeys: String, CodingKey {
        case category
        case label
        case responseClass = "class"
        case href
        case links = "link"
        case notes = "note"
    }

    public struct Category: Decodable, Equatable {
        public var indices: Indices?
        public var labels: [String: String]?
        public var children: [String: [String]]?
        public var coordinates: [String: [Double]]?
        public var units: [String: Unit]?
        public var notes: [String: [String]]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            indices = try container.decodeIfPresent(Indices.self, forKey: .indices)
            labels = try container.decodeIfPresent([String: String].self, forKey: .labels)
            children = try container.decodeIfPresent([String: [String]].self, forKey: .children)
            coordinates = try container.decodeIfPresent([String: [Double]].self, forKey: .coordinates)
            units = try container.decodeIfPresent([String: Unit].self, forKey: .units)
            notes = try container.decodeIfPresent([String: [String]].self, forKey: .notes)
        }

        private enum CodingKeys: String, CodingKey {
            case indices = "index"
            case labels = "label"
            case children = "child"
            case coordinates
            case units = "unit"
            case notes = "note"
        }

        public struct Unit: Decodable, Equatable {
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
