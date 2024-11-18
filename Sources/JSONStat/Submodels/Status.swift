//
//  Status.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 18/11/2024.
//

public enum Status: Codable, Equatable {
    case array([String?])
    case dictionary([String: String?])
    case string(String)

    public init(from decoder: any Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Status must be an array, dictionary or string"))
        }
        if let values = try? container.decode([String?].self) {
            self = .array(values)
        } else if let dictionary = try? container.decode([String: String?].self) {
            self = .dictionary(dictionary)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            throw DecodeError.unsupportedStatus
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let array):
            try container.encode(array)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        case .string(let string):
            try container.encode(string)
        }
    }
}
