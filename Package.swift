// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EChargerHelper",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "EChargerHelper",
            targets: ["EChargerHelper"]),
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        // JSON Decoding
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "EChargerHelper",
            dependencies: [
                "Alamofire",
                "AnyCodable"
            ]),
        .testTarget(
            name: "EChargerHelperTests",
            dependencies: ["EChargerHelper"]),
    ]
)