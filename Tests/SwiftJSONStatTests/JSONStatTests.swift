@testable import SwiftJSONStat
import XCTest

final class JSONStatTests: XCTestCase {
    func testDecodeDanish() throws {
        let json = """
        {
          "dataset": {
            "dimension": {
              "BEVÆGELSE": {
                "label": "bevægelsesart",
                "category": {
                  "index": {
                    "M+K": 0,
                    "M": 1,
                    "K": 2
                  },
                  "label": {
                    "M+K": "Befolkning 1. januar (i 1000)",
                    "M": "Mænd 1. januar (i 1000)",
                    "K": "Kvinder 1. januar (i 1000)"
                  }
                }
              },
              "ContentsCode": {
                "label": "Indhold",
                "category": {
                  "index": {
                    "HISB3": 0
                  },
                  "label": {
                    "HISB3": "Nøgletal om befolkningen"
                  },
                  "unit": {
                    "HISB3": {
                      "base": "Antal",
                      "decimals": 0
                    }
                  }
                }
              },
              "Tid": {
                "label": "tid",
                "category": {
                  "index": {
                    "2022": 0,
                    "2023": 1
                  },
                  "label": {
                    "2022": "2022",
                    "2023": "2023"
                  }
                }
              },
              "id": [
                "BEVÆGELSE",
                "ContentsCode",
                "Tid"
              ],
              "size": [
                3,
                1,
                2
              ],
              "role": {
                "metric": [
                  "ContentsCode"
                ],
                "time": [
                  "Tid"
                ]
              }
            },
            "label": "Nøgletal om befolkningen efter bevægelsesart, Indhold og tid",
            "source": "Danmarks Statistik",
            "updated": "2023-06-02T06:00:00Z",
            "value": [
              5873,
              5933,
              2923,
              2949,
              2951,
              2984
            ],
            "extension": {
              "px": {
                "infofile": "https://www.dst.dk/statistikdokumentation/4a12721d-a8b0-4bde-82d7-1d1c6f319de3",
                "tableid": "HISB3",
                "decimals": 0
              }
            }
          }
        }
        """
        let decoder = JSONStat.decoder
        let jsonStat = try decoder.decode(JSONStat.self, from: json.data(using: .utf8)!)
        guard case .v1(let jsonStatV1) = jsonStat else {
            XCTFail(); return
        }
        XCTAssertEqual(jsonStatV1.dataset.dimensionsInfo.dimensions.count, 3)
    }
}
