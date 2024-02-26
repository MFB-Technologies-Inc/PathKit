// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PathKit",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15), .macCatalyst(.v15), .visionOS(.v1)],
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

#if !canImport(System)
    package.dependencies += [.package(url: "https://github.com/apple/swift-system.git", from: "1.2.1")]
    for target in package.targets {
        if target.name == "PathKit" {
            target.dependencies += [Target.Dependency.product(name: "SystemPackage", package: "swift-system")]
        }
    }
#endif

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
