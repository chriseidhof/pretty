// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pretty",
    products: [
        .library(
            name: "Pretty",
            targets: ["Pretty"]),
        .library(
            name: "SwiftBuilder",
            targets: ["SwiftBuilder"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pretty",
            dependencies: []),
        .target(
            name: "SwiftBuilder",
            dependencies: ["Pretty"]),
        .testTarget(
            name: "PrettyTests",
            dependencies: ["Pretty", "SwiftBuilder"]),
    ]
)
