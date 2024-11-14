//
//  JSONStatV2.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

public struct JSONStatV2: Codable {
    var version: String
    var label: String?
    var responseClass: ResponseClass?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        responseClass = try ResponseClass(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(label, forKey: .label)
        try responseClass?.encode(to: encoder)
    }

    internal enum CodingKeys: CodingKey {
        case version
        case label
        case `class`
    }
}
