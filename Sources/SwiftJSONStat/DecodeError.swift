//
//  DecodeError.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

enum DecodeError: Error {
    case unsupportedVersion
    case unsupportedClass
    case unupportedUpdatedFormat(dateString: String)
    case unsupportedValues
    case unsupportedIndex
}
