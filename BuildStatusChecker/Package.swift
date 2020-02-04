// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildStatusChecker",
    platforms: [ .iOS(.v13), .macOS(.v10_15) ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BuildStatusChecker",
            targets: ["BuildStatusChecker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.2")),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMajor(from: "19.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BuildStatusChecker",
            dependencies: ["KeychainSwift"]),
        .testTarget(
            name: "BuildStatusCheckerTests",
            dependencies: [
                "BuildStatusChecker",
                "Quick",
                "Nimble"
            ]
        ),
    ]
)
