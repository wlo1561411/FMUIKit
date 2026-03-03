// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FMUIKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FMUIKit",
            targets: ["FMUIKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FMUIKit",
            dependencies: [
                "SnapKit",
            ],
            swiftSettings: [
                .swiftLanguageMode(.version("5.10"))
            ],
        ),
        .testTarget(
            name: "FMUIKitTests",
            dependencies: [
                "FMUIKit",
            ],
            swiftSettings: [
                .swiftLanguageMode(.version("5.10"))
            ],
        ),
    ]
)
