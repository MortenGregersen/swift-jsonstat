//
//  MissingCaseTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 20/11/2024.
//

import JSONStat
import Testing

struct MissingCaseTests {
    @Test func stringStatus() throws {
        let json = """
        {
          "class" : "dataset",
          "dimension" : {

          },
          "id" : [

          ],
          "label" : null,
          "size" : [

          ],
          "status" : "something",
          "updated" : "2024-11-20T08:00:00Z",
          "value" : [

          ],
          "version" : "2.0"
        }
        """
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat,
              case .dataset(let dataset) = jsonStatV2.responseClass else {
            fatalError()
        }
        #expect(dataset.status == .string("something"))
        let encodedJSON = try JSONStat.encoder.encode(jsonStat)
        #expect(String(data: encodedJSON, encoding: .utf8)! == json)
    }

    @Test func dimensionClass() throws {
        let json = """
        {
          "category" : {
            "index" : [
              "1",
              "2",
              "3"
            ]
          },
          "class" : "dimension",
          "label" : "A: 3-categories dimension",
          "version" : "2.0"
        }
        """
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat,
              case .dimension = jsonStatV2.responseClass else {
            fatalError()
        }
        let encodedJSON = try JSONStat.encoder.encode(jsonStat)
        #expect(String(data: encodedJSON, encoding: .utf8)! == json)
    }

    @Test func collectionLink() throws {
        let json = """
        {
          "class" : "collection",
          "href" : "https://json-stat.org/samples/collection.json",
          "label" : "JSON-stat Dataset Sample Collection",
          "link" : {
            "item" : [
              {
                "class" : "collection",
                "href" : "https://json-stat.org/samples/inner-collection.json",
                "label" : "JSON-stat Dataset Sample Inner Collection",
                "link" : {
                  "item" : [
                    {
                      "class" : "dataset",
                      "href" : "https://json-stat.org/samples/oecd.json",
                      "label" : "Unemployment rate in the OECD countries 2003-2014"
                    },
                    {
                      "class" : "dataset",
                      "href" : "https://json-stat.org/samples/canada.json",
                      "label" : "Population by sex and age group. Canada. 2012"
                    }
                  ]
                }
              }
            ]
          },
          "updated" : "2015-07-01T22:00:00Z",
          "version" : "2.0"
        }
        """
        let jsonStat = try JSONStat.decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v2(let jsonStatV2) = jsonStat,
              case .collection(let outerCollection) = jsonStatV2.responseClass,
              let links = outerCollection.links,
              case .collection = links["item"]?.first else {
            fatalError()
        }
        let encodedJSON = try JSONStat.encoder.encode(jsonStat)
        #expect(String(data: encodedJSON, encoding: .utf8)! == json)
    }
}
