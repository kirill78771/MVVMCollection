// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MVVMCollection",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "MVVMCollection",
            targets: ["MVVMCollection"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MVVMCollection",
            dependencies: []),
        .testTarget(
            name: "MVVMCollectionTests",
            dependencies: ["MVVMCollection"]),
    ]
)
