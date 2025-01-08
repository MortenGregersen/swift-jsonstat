//
//  Link.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public enum Link: Codable, Equatable, Sendable {
    case nonJSONStat(type: String, href: URL)
    case jsonStat(class: String, href: URL, label: String, extension: JSON?)
    case dataset(JSONStatV2.Dataset, extension: JSON?)
    case collection(ResponseClass.Collection, extension: JSON?)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let responseClass = try container.decodeIfPresent(String.self, forKey: .class) else {
            let type = try container.decode(String.self, forKey: .type)
            let href = try container.decode(URL.self, forKey: .href)
            self = .nonJSONStat(type: type, href: href)
            return
        }
        let `extension` = try container.decodeIfPresent(JSON.self, forKey: .extension)
        if responseClass == "dataset" {
            if container.contains(.value) {
                self = try .dataset(.init(from: decoder), extension: `extension`)
            } else {
                let href = try container.decode(URL.self, forKey: .href)
                let label = try container.decode(String.self, forKey: .label)
                self = .jsonStat(class: responseClass, href: href, label: label, extension: `extension`)
            }
        } else if responseClass == "collection" {
            self = try .collection(.init(from: decoder), extension: `extension`)
        } else {
            throw DecodeError.unsupportedLink
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .nonJSONStat(let type, let href):
            try container.encode(type, forKey: .type)
            try container.encode(href, forKey: .href)
        case .jsonStat(let responseClass, let href, let label, let `extension`):
            try container.encode(responseClass, forKey: .class)
            try container.encode(href, forKey: .href)
            try container.encode(label, forKey: .label)
            try container.encodeIfPresent(`extension`, forKey: .extension)
        case .dataset(let dataset, let `extension`):
            try container.encode("dataset", forKey: .class)
            try container.encodeIfPresent(`extension`, forKey: .extension)
            try dataset.encode(to: encoder)
        case .collection(let collection, let `extension`):
            try container.encode("collection", forKey: .class)
            try container.encodeIfPresent(`extension`, forKey: .extension)
            try collection.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case `class`
        case type
        case href
        case label
        case value
        case `extension`
    }
}
