// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "PathKit",
    platforms: [.iOS(.v12), .macOS(.v10_13), .watchOS(.v4), .tvOS(.v12), .macCatalyst(.v13)],
    products: [
        .library(name: "PathKit", targets: ["PathKit"]),
    ],
    targets: [
        .target(
            name: "PathKit",
            swiftSettings: .swiftSix
        ),
        .testTarget(
            name: "PathKitTests",
            dependencies: [
                "PathKit",
            ],
            swiftSettings: .swiftSix
        ),
    ]
)

extension [SwiftSetting] {
    static let swiftSix: [SwiftSetting] = [
        .enableUpcomingFeature("BareSlashRegexLiterals"),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("ForwardTrailingClosures"),
        .enableUpcomingFeature("ImplicitOpenExistentials"),
        .enableUpcomingFeature("StrictConcurrency"),
    ]
}
