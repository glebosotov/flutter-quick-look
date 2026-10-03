// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "quick_look",
    platforms: [.iOS("13.0")],
    products: [
        .library(name: "quick-look", targets: ["quick_look"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "quick_look",
            dependencies: [.product(name: "FlutterFramework", package: "FlutterFramework")]
        )
    ]
)
