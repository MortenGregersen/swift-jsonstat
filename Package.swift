// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let testResources: [Resource] = [
    .copy("../Samples/DKStatbank"),
    .copy("../Samples/Eurostat"),
    .copy("../Samples/JSONStatOrg")
]

let package = Package(
    name: "swift-jsonstat",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "JSONStatDecoder",
            targets: ["JSONStatDecoder"]),
    ],
    targets: [
        .target(name: "JSONStatDecoder"),
        .testTarget(name: "JSONStatDecoderTests",
                    dependencies: ["JSONStatDecoder"],
                    resources: testResources),
    ])
