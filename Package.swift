// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cronner",
    products: [
        .library(
            name: "Cronner",
            targets: ["Cronner"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Cronner",
            dependencies: []),
        .testTarget(
            name: "CronnerTests",
            dependencies: ["Cronner"]),
    ]
)
