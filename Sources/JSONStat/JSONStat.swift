//
//  JSONStat.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public enum JSONStat: Codable, Equatable, Sendable {
    case v1(JSONStatV1)
    case v2(JSONStatV2)

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            } else if let date = dateFormatter.date(from: dateString) {
                return date
            }
            throw DecodeError.unsupportedUpdatedFormat(dateString: dateString)
        }
        return decoder
    }()
    
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONStatV2.CodingKeys.self)
        if let version = try container.decodeIfPresent(String.self, forKey: JSONStatV2.CodingKeys.version) {
            guard version.hasPrefix("2.") else { throw DecodeError.unsupportedVersion }
            self = try .v2(JSONStatV2(from: decoder))
        } else {
            self = try .v1(JSONStatV1(from: decoder))
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .v1(let jsonStatV1):
            try container.encode(jsonStatV1)
        case .v2(let jsonStatV2):
            try container.encode(jsonStatV2)
        }
    }
}
