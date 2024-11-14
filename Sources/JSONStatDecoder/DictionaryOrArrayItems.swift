//
//  DictionaryOrArrayItems.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

public enum DictionaryOrArrayItems<ArrayValue, DictValue>: Codable where ArrayValue: Codable, DictValue: Codable {
    case array([ArrayValue?])
    case dictionary([String: DictValue?])

    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Values must be an array or dictionary"))
        }
        if let values = try? container.decode([ArrayValue?].self) {
            self = .array(values)
        } else if let dictionary = try? container.decode([String: DictValue?].self) {
            self = .dictionary(dictionary)
        } else {
            throw DecodeError.unsupportedValues
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .array(let values):
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: values)
        case .dictionary(let dictionary):
            var container = encoder.singleValueContainer()
            try container.encode(dictionary)
        }
    }
}

public enum Values: Codable {
    case numbers(DictionaryOrArrayItems<Double, Double>)
    case strings(DictionaryOrArrayItems<String, String>)

    public init(from decoder: any Decoder) throws {
        if let numbers = try? DictionaryOrArrayItems<Double, Double>(from: decoder) {
            self = .numbers(numbers)
        } else if let strings = try? DictionaryOrArrayItems<String, String>(from: decoder) {
            self = .strings(strings)
        } else {
            throw DecodeError.unsupportedValues
        }
    }
}

public typealias Indices = DictionaryOrArrayItems<String, Int>
public typealias Status = DictionaryOrArrayItems<String, String>
