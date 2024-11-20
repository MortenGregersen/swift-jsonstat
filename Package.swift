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
            name: "JSONStat",
            targets: ["JSONStat"]),
        .library(
            name: "JSONStatTable",
            targets: ["JSONStatTable"]),
        .library(
            name: "JSONStatConverter",
            targets: ["JSONStatConverter"]),
    ],
    targets: [
        .target(name: "JSONStat"),
        .testTarget(name: "JSONStatTests",
                    dependencies: ["JSONStat"],
                    resources: testResources),
        .target(name: "JSONStatTable",
                dependencies: ["JSONStat"]),
        .testTarget(name: "JSONStatTableTests",
                    dependencies: ["JSONStatTable"],
                    resources: testResources),
        .target(name: "JSONStatConverter",
                dependencies: ["JSONStat", "JSONStatTable"]),
        .testTarget(name: "JSONStatConverterTests",
                    dependencies: ["JSONStatConverter"],
                    resources: testResources)
    ])
