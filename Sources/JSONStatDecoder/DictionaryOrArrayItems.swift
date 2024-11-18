//
//  DictionaryOrArrayItems.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Foundation

public enum DictionaryOrArrayItems<ArrayValue, DictValue>: Decodable, Equatable where ArrayValue: Decodable & Equatable, DictValue: Decodable & Equatable {
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

public enum Values: Decodable, Equatable {
    case numbers(DictionaryOrArrayItems<Double, Double>)
    case strings(DictionaryOrArrayItems<String, String>)

    public var count: Int {
        switch self {
        case .numbers(let dictionaryOrArrayItems):
            switch dictionaryOrArrayItems {
            case .array(let array): array.count
            case .dictionary(let dictionary): dictionary.count
            }
        case .strings(let dictionaryOrArrayItems):
            switch dictionaryOrArrayItems {
            case .array(let array): array.count
            case .dictionary(let dictionary): dictionary.count
            }
        }
    }

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
