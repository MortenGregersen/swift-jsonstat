// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
            name: "SwiftJSONStat",
            targets: ["SwiftJSONStat"]),
    ],
    targets: [
        .target(
            name: "SwiftJSONStat"),
        .testTarget(
            name: "SwiftJSONStatTests",
            dependencies: ["SwiftJSONStat"],
            resources: [.copy("Examples")]),
    ]
)
