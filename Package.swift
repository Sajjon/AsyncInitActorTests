// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIGActor",
	platforms: [.macOS(.v12), .iOS(.v16)],
    products: [
        .library(
            name: "AIGActor",
            targets: ["AIGActor"]),
    ],
	dependencies: [
		.package(url: "https://github.com/apple/swift-atomics", from: "1.1.0"),
		.package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.0.0"),
	],
    targets: [
        .target(
            name: "AIGActor",
			dependencies: [
				.product(
					name: "Atomics",
					package: "swift-atomics"
				),
				.product(
					name: "ConcurrencyExtras",
					package: "swift-concurrency-extras"
				),
			]
		),
        .testTarget(
            name: "AIGActorTests",
            dependencies: ["AIGActor"]),
    ]
)
