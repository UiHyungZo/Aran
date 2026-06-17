// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AranData",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AranData", targets: ["AranData"])
    ],
    dependencies: [
        .package(path: "../AranDomain"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0")
    ],
    targets: [
        .target(
            name: "AranData",
            dependencies: [
                "AranDomain",
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Sources/AranData"
        )
    ]
)
