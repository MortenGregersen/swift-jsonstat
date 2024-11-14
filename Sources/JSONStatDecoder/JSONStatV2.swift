//
//  JSONStatV2.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

public struct JSONStatV2: Decodable {
    public var version: String
    public var label: String?
    public var responseClass: ResponseClass?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        responseClass = try ResponseClass(from: decoder)
    }

    internal enum CodingKeys: CodingKey {
        case version
        case label
        case `class`
    }
}
