// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ShiningSun",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ShiningSun", targets: ["ShiningSun"])
    ],
    targets: [
        .executableTarget(
            name: "ShiningSun",
            path: "Sources/ShiningSun"
        ),
        .testTarget(
            name: "ShiningSunTests",
            dependencies: ["ShiningSun"],
            path: "Tests/ShiningSunTests"
        )
    ]
)
