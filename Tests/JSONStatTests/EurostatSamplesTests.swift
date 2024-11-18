import Testing

// Samples from https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/api-statistics

struct EurostatSamplesTests {
    @Test func DecodeNama10gdp() throws {
        try decodeAndEncodeSample(named: "Eurostat/nama_10_gdp")
    }
    
    @Test func DecodeDemoGind() throws {
        try decodeAndEncodeSample(named: "Eurostat/demo_gind")
    }
}
