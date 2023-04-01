// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CMDS",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CMDS",
            targets: ["CMDS", "Pick", "ProgressBar", "XCTools"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pakLebah/ANSITerminal", from: "0.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CMDS",
            dependencies: ["Internals", "ANSITerminal"]),
        .target(
            name: "XCTools",
            dependencies: ["CMDS", "Internals"]
        ),
        .target(
            name: "ProgressBar",
            dependencies: ["Internals", "ANSITerminal"]
        ),
        .target(
            name: "Pick",
            dependencies: ["Internals", "ANSITerminal"]
        ),
        .target(name: "Internals"),
        .testTarget(
            name: "CMDSTests",
            dependencies: ["CMDS"]),
    ]
)
