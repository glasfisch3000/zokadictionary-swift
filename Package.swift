// swift-tools-version:6.4
import PackageDescription

let package = Package(
    name: "zokadictionary",
    platforms: [
       .macOS(.v15),
    ],
    products: [
        .executable(name: "App", targets: ["zokadictionary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
		.package(url: "https://github.com/vapor/leaf.git", from: "4.4.0"),
		.package(url: "https://github.com/tmthecoder/Argon2Swift.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "zokadictionary",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
				.product(name: "Leaf", package: "leaf"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
				.product(name: "Argon2Swift", package: "Argon2Swift"),
            ],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=50"], .when(configuration: .debug)),
			]
        ),
    ]
)
