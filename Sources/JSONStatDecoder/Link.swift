//
//  Link.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public enum Link: Decodable, Equatable {
    case nonJSONStat(type: String, href: URL)
    case jsonStat(class: String, href: URL, label: String)
    case dataset(JSONStatV2.Dataset)
    case collection(ResponseClass.Collection)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let responseClass = try container.decodeIfPresent(String.self, forKey: .class) else {
            let type = try container.decode(String.self, forKey: .type)
            let href = try container.decode(URL.self, forKey: .href)
            self = .nonJSONStat(type: type, href: href)
            return
        }
        guard container.contains(.value) else {
            let href = try container.decode(URL.self, forKey: .href)
            let label = try container.decode(String.self, forKey: .label)
            self = .jsonStat(class: responseClass, href: href, label: label)
            return
        }
        if responseClass == "dataset" {
            self = try .dataset(.init(from: decoder))
        } else if responseClass == "collection" {
            self = try .collection(.init(from: decoder))
        } else {
            throw DecodingError.dataCorruptedError(forKey: .class, in: container, debugDescription: "Unknown class for link")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case `class`
        case type
        case href
        case label
        case value
    }
}
