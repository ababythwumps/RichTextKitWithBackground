// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RichTextKitWithBackground",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "RichTextKitWithBackground",
            targets: ["RichTextKitWithBackground"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ababythwumps/RichTextKitWithBackground.git",
            .upToNextMajor(from: "1.5.0")
        )
    ],
    targets: [
        .target(
            name: "RichTextKitWithBackground",
            dependencies: [],
            resources: [.process("Resources")],
            swiftSettings: [
                .define("macOS", .when(platforms: [.macOS])),
                .define("iOS", .when(platforms: [.iOS, .macCatalyst]))
            ]
        ),
        .testTarget(
            name: "RichTextKitTests",
            dependencies: ["RichTextKit", "MockingKit"],
            swiftSettings: [
                .define("macOS", .when(platforms: [.macOS])),
                .define("iOS", .when(platforms: [.iOS, .macCatalyst]))
            ]
        )
    ]
)
