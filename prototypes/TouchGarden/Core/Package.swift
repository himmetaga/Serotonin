// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SerotoninCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SerotoninCore", targets: ["SerotoninCore"])
    ],
    targets: [
        .target(name: "SerotoninCore"),
        .testTarget(name: "SerotoninCoreTests", dependencies: ["SerotoninCore"])
    ]
)
