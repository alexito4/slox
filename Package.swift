// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "slox",
    targets: [
        Target(
            name: "slox",
            dependencies: ["LoxCore"]
        ),
        Target(name: "LoxCore"),
        Target(name: "GenerateAst")
    ],
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git",
                 majorVersion: 3)
    ]
)
