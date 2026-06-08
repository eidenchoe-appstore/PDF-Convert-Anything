// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PDFConvertAnything",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PDFConvertAnythingCore",
            targets: ["PDFConvertAnythingCore"]
        ),
        .executable(
            name: "PDFConvertAnything",
            targets: ["PDFConvertAnything"]
        )
    ],
    targets: [
        .target(
            name: "PDFConvertAnythingCore"
        ),
        .executableTarget(
            name: "PDFConvertAnything",
            dependencies: ["PDFConvertAnythingCore"]
        ),
        .testTarget(
            name: "PDFConvertAnythingCoreTests",
            dependencies: ["PDFConvertAnythingCore"]
        )
    ]
)
