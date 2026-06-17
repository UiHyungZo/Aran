// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AranDomain",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AranDomain", targets: ["AranDomain"])
    ],
    targets: [
        .target(
            name: "AranDomain",
            path: "Sources/AranDomain"
        )
    ]
)
