//
//  JSONTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 21/11/2024.
//

import Foundation
import JSONStat
import Testing

struct JSONTests {
    @Test func EncodingDecoding() throws {
        let jsonString = """
        {
          "array" : [
            "item1",
            2,
            false,
            null
          ],
          "boolean_false" : false,
          "boolean_true" : true,
          "empty_array" : [

          ],
          "empty_object" : {

          },
          "float" : 3.14,
          "null_value" : null,
          "number" : 42,
          "object" : {
            "nested_number" : 100,
            "nested_string" : "Nested value"
          },
          "string" : "Hello, world!"
        }
        """
        let decoder = JSONDecoder()
        let jsonFromString = try decoder.decode(JSON.self, from: Data(jsonString.utf8))

        let jsonDescription = jsonFromString.description
        let jsonFromDescription = try decoder.decode(JSON.self, from: Data(jsonDescription.utf8))

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let encodedJsonString = try encoder.encode(jsonFromString)
        let encodedJsonDescription = try encoder.encode(jsonFromDescription)
        #expect(String(data: encodedJsonString, encoding: .utf8)! == jsonString)
        #expect(String(data: encodedJsonDescription, encoding: .utf8) == jsonString)
    }

    @Test func Convenience() {
        let object = JSON.object([.init(stringValue: "nested")!: .object([.init(stringValue: "nestedNested")!: .number(42)])])
        let array = JSON.array([.number(13), .number(37)])
        let string = JSON.string("something")
        let double = JSON.number(13.37)
        let int = JSON.number(42)
        let bool = JSON.bool(true)
        #expect(object.objectValue != nil)
        #expect(array.objectValue == nil)
        #expect(array.arrayValue != nil)
        #expect(string.arrayValue == nil)
        #expect(string.stringValue != nil)
        #expect(double.stringValue == nil)
        #expect(double.doubleValue != nil)
        #expect(int.doubleValue == 42)
        #expect(int.intValue != nil)
        #expect(bool.intValue == nil)
        #expect(bool.boolValue != nil)
        #expect(object.boolValue == nil)
        
        #expect(double.intValue == 13)
        #expect(string.doubleValue == nil)
        
        #expect(object.nested["nestedNested"]?.intValue == 42)
        #expect(object.invalid == .null)
        #expect(array[1]?.intValue == 37)
        #expect(string[1] == nil)
    }

    @Test func IntDynamicCodingKeys() {
        #expect(JSON.Key(intValue: 8) == nil)
        #expect(JSON.Key(stringValue: "some_key")?.intValue == nil)
    }
}
