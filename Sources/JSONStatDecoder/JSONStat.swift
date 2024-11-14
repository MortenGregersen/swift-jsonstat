//
//  JSONStat.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public enum JSONStat: Decodable {
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
            throw DecodeError.unupportedUpdatedFormat(dateString: dateString)
        }
        return decoder
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
}
