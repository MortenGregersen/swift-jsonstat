//
//  JSONStatToCSVConverterJSONStatOrgTests.swift
//  swift-jsonstat
//
//  Created by Morten Bjerg Gregersen on 14/11/2024.
//

import Testing

struct JSONStatToCSVConverterJSONStatOrgTests {
    @Test func convertCanadaToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/canada")
    }
    
    @Test func convertGaliciaToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/galicia")
    }
    
    @Test func convertHierarchyToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/hierarchy")
    }
    
    @Test func convertOECD_Canada() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/oecd-canada")
    }
    
    @Test func convertOECD_Canada_ColToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/oecd-canada-col")
    }
    
    @Test func convertOrderToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/order")
    }
    
    @Test func convertUS_GSPToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/us-gsp")
    }
    
    @Test func convertUS_LaborToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/us-labor")
    }
    
    @Test func convertUS_UNRToCSV() throws {
        try convertToCSVAndCompareToSnapshot(named: "JSONStatOrg/us-unr")
    }
}
