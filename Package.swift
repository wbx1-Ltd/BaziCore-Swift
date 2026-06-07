// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BaziCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "BaziCore", targets: ["BaziCore"]),
        .library(name: "BaziCoreTables", targets: ["BaziCoreTables"]),
        .library(name: "BaziCoreLunarCoreAdapter", targets: ["BaziCoreLunarCoreAdapter"]),
        .library(name: "BaziCoreAstronomy", targets: ["BaziCoreAstronomy"]),
        .library(name: "BaziCoreLuck", targets: ["BaziCoreLuck"]),
        .library(name: "BaziCoreTesting", targets: ["BaziCoreTesting"])
    ],
    dependencies: [
        .package(url: "https://github.com/wbx1-Ltd/LunarCore-Swift.git", from: "1.2.0"),
        .package(url: "https://github.com/wbx1-Ltd/AstroCore-Swift.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "BaziCore"),
        .target(
            name: "BaziCoreTables",
            dependencies: ["BaziCore"]
        ),
        .target(
            name: "BaziCoreLunarCoreAdapter",
            dependencies: [
                "BaziCore",
                .product(name: "LunarCore", package: "LunarCore-Swift")
            ]
        ),
        .target(
            name: "BaziCoreAstronomy",
            dependencies: [
                "BaziCore",
                .product(name: "AstroCore", package: "AstroCore-Swift")
            ]
        ),
        .target(
            name: "BaziCoreLuck",
            dependencies: ["BaziCore", "BaziCoreTables"]
        ),
        .target(
            name: "BaziCoreTesting",
            dependencies: ["BaziCore"]
        ),
        // Developer tool: regenerates the golden fixtures from BaziCore's own
        // engines, so the committed baselines are self-produced.
        .executableTarget(
            name: "BaziCoreFixtureGen",
            dependencies: ["BaziCore", "BaziCoreAstronomy", "BaziCoreTesting"]
        ),
        .testTarget(
            name: "BaziCoreTests",
            dependencies: [
                "BaziCore",
                "BaziCoreTables",
                "BaziCoreLunarCoreAdapter",
                "BaziCoreAstronomy",
                "BaziCoreLuck",
                "BaziCoreTesting"
            ]
        ),
        .testTarget(
            name: "BaziCoreTablesTests",
            dependencies: ["BaziCoreTables"]
        ),
        .testTarget(
            name: "BaziCoreLunarCoreAdapterTests",
            dependencies: ["BaziCoreLunarCoreAdapter"]
        ),
        .testTarget(
            name: "BaziCoreAstronomyTests",
            dependencies: ["BaziCoreAstronomy"]
        ),
        .testTarget(
            name: "BaziCoreLuckTests",
            dependencies: ["BaziCoreLuck", "BaziCoreTables", "BaziCoreAstronomy"]
        ),
        .testTarget(
            name: "BaziCoreFixtureTests",
            dependencies: [
                "BaziCore",
                "BaziCoreTesting",
                "BaziCoreAstronomy",
                "BaziCoreLunarCoreAdapter",
                "BaziCoreLuck"
            ],
            resources: [.process("Fixtures")]
        )
    ]
)
