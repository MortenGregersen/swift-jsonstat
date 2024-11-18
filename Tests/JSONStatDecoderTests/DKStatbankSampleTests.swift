import Testing

// Samples from https://api.statbank.dk/console#data

struct DKStatbankSamplesTests {
    @Test func DecodeHISB3() throws {
        try decodeAndEncodeSample(named: "DKStatbank/HISB3")
    }
}
