import Foundation
import JSONStatDecoder
import Testing

// Samples from https://json-stat.org/format/

struct JSONStatOrgSamplesTests {
    @Test func DecodeCanada() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/canada")
    }

    @Test func DecodeCollection() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/collection")
    }

    @Test func DecodeGalicia() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/galicia")
    }

    @Test func DecodeHierarchy() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/hierarchy")
    }

    @Test func DecodeOECD_Canada() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/oecd-canada")
    }

    @Test func DecodeOECD_Canada_COL() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/oecd-canada-col")
    }

    @Test func DecodeOrder() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/order")
    }

    @Test func DecodeUS_GSP() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/us-gsp")
    }

    @Test func DecodeUS_Labor() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/us-labor")
    }

    @Test func DecodeUS_UNR() throws {
        try decodeAndEncodeSample(named: "JSONStatOrg/us-unr")
    }
}
