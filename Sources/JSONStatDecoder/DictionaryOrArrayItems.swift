//
//  DictionaryOrArrayItems.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

public enum DictionaryOrArrayItems<ArrayValue, DictValue>: Decodable where ArrayValue: Decodable, DictValue: Decodable {
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
}

public enum Values: Decodable {
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
