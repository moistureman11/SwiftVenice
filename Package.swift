// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "FayeBlade",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FayeBlade",
            targets: ["FayeBlade"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FayeBlade",
            dependencies: [],
            path: "FayeBlade"
        ),
    ]
)