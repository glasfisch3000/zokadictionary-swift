// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "zokadictionary",
    platforms: [
       .macOS(.v13),
    ],
    products: [
        .executable(name: "App", targets: ["zokadictionary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.3"),
    ],
    targets: [
        .executableTarget(
            name: "zokadictionary",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "_NIOFileSystem", package: "swift-nio"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
    ]
)
