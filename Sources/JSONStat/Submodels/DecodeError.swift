//
//  DecodeError.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

public enum DecodeError: Error, Equatable {
    case unsupportedVersion
    case unsupportedClass
    case unsupportedUpdatedFormat(dateString: String)
    case unsupportedValues
    case unsupportedIndex
    case unsupportedStatus
}
