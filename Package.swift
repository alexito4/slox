// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "slox",
    products: [
        .executable(
            name: "slox",
            targets: ["slox"]),
        .executable(
            name: "GenerateAst",
            targets: ["GenerateAst"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", from: "3.2.4")
    ],
    targets: [
        .target(
            name: "slox",
            dependencies: ["LoxCore"]
        ),
        .target(name: "LoxCore", dependencies: ["Result"]),
        .target(name: "GenerateAst")
    ]
)
