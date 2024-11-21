//
//  JSON.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 18/11/2024.
//

import Foundation

// Borrowed from: https://gist.github.com/rnapier/d91175be2f737aca7ad476759948666e

@dynamicMemberLookup
public enum JSON: Codable, CustomStringConvertible, Equatable {
    public var description: String {
        switch self {
        case .string(let string): return "\"\(string)\""
        case .number(let double):
            if let int = Int(exactly: double) {
                return "\(int)"
            }
            else {
                return "\(double)"
            }
        case .object(let object):
            let keyValues = object
                .map { key, value in "\"\(key)\": \(value)" }
                .joined(separator: ",")
            return "{\(keyValues)}"
        case .array(let array):
            return "\(array)"
        case .bool(let bool):
            return "\(bool)"
        case .null:
            return "null"
        }
    }

    public struct Key: CodingKey, Hashable, CustomStringConvertible {
        public var description: String {
            stringValue
        }

        public let stringValue: String
        init(_ string: String) { self.stringValue = string }
        public init?(stringValue: String) { self.init(stringValue) }
        public var intValue: Int? { nil }
        public init?(intValue: Int) { nil }
    }

    case string(String)
    case number(Double)
    case object([Key: JSON])
    case array([JSON])
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) { self = .string(string) }
        else if let number = try? decoder.singleValueContainer().decode(Double.self) { self = .number(number) }
        else if let object = try? decoder.container(keyedBy: Key.self) {
            var result: [Key: JSON] = [:]
            for key in object.allKeys {
                result[key] = (try? object.decode(JSON.self, forKey: key)) ?? .null
            }
            self = .object(result)
        }
        else if var array = try? decoder.unkeyedContainer() {
            var result: [JSON] = []
            for _ in 0 ..< (array.count ?? 0) {
                try result.append(array.decode(JSON.self))
            }
            self = .array(result)
        }
        else if let bool = try? decoder.singleValueContainer().decode(Bool.self) { self = .bool(bool) }
        else if let isNull = try? decoder.singleValueContainer().decodeNil(), isNull { self = .null }
        else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown JSON type")) }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .number(let number):
            var container = encoder.singleValueContainer()
            try container.encode(number)
        case .bool(let bool):
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        case .object(let object):
            var container = encoder.container(keyedBy: Key.self)
            for (key, value) in object {
                try container.encode(value, forKey: key)
            }
        case .array(let array):
            var container = encoder.unkeyedContainer()
            for value in array {
                try container.encode(value)
            }
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

    public var objectValue: [String: JSON]? {
        switch self {
        case .object(let object):
            let mapped: [String: JSON] = Dictionary(uniqueKeysWithValues:
                object.map { key, value in (key.stringValue, value) })
            return mapped
        default: return nil
        }
    }

    public var arrayValue: [JSON]? {
        switch self {
        case .array(let array): array
        default: nil
        }
    }

    public var stringValue: String? {
        switch self {
        case .string(let string): string
        default: nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .number(let number): number
        default: nil
        }
    }

    public var intValue: Int? {
        switch self {
        case .number(let number): Int(number)
        default: nil
        }
    }

    public var boolValue: Bool? {
        switch self {
        case .bool(let bool): bool
        default: nil
        }
    }
    
    public subscript(index: Int) -> JSON? {
        switch self {
        case .array(let array): array[index]
        default: nil
        }
    }
    
    public subscript(key: String) -> JSON? {
        guard let jsonKey = Key(stringValue: key),
              case .object(let object) = self,
              let value = object[jsonKey]
        else { return nil }
        return value
    }
    
    public subscript(dynamicMember member: String) -> JSON {
        self[member] ?? .null
    }
}
