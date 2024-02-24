// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Expressive", 
    products: [
        .library(
            name: "Expressive",
            targets: ["Expressive"]),
    ],
    dependencies: [
        .package(url: "https://github.com/entonio/Nuggle.git", "0.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "Expressive",
            dependencies: [.product(name: "Nuggle", package: "Nuggle")]
        ),
        .testTarget(
            name: "ExpressiveTests",
            dependencies: ["Expressive"]),
    ]
)
