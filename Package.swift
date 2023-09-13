// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AsyncInitializedStore",
    platforms: [.macOS(.v12), .iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics", from: "1.1.0"),
    ],
    targets: [
        .testTarget(
            name: "Tests",
            dependencies: [
                .product(
                    name: "Atomics",
                    package: "swift-atomics"
                ),
            ]

        ),
    ]
)
