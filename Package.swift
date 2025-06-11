// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CLAID",
    platforms: [
        .iOS(.v18), // or whichever platforms you support
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CLAID",
            targets: ["CLAID"])
    ],
    dependencies: [
         .package(url: "https://github.com/grpc/grpc-swift.git", from: "2.0.0"),
         .package(url: "https://github.com/grpc/grpc-swift-nio-transport.git", from: "1.0.0"),
         .package(url: "https://github.com/grpc/grpc-swift-protobuf.git", from: "1.0.0"),
         .package(url: "https://github.com/StanfordSpezi/Spezi", branch: "main"),
         

     ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CLAID",
            dependencies: [
                "CLAIDNative",
                .product(name: "GRPCCore", package: "grpc-swift"),
                .product(name: "GRPCNIOTransportHTTP2", package: "grpc-swift-nio-transport"),
                .product(name: "GRPCProtobuf", package: "grpc-swift-protobuf"),
                .product(name: "Spezi", package: "Spezi"),
            ],
            path: "CLAID/Sources/CLAID"
            // plugins: [
            //        .plugin(name: "GRPCProtobufGenerator", package: "grpc-swift-protobuf")
            //     ]
        ),
        // Trick to generate binding headers:
        // create a regular target which depends on the xcframework as binary target.
        .target(
            name: "CLAIDNative",
            dependencies: ["native_xcframework"],
            path: "CLAID/Sources/CLAIDNative",
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-std=c++17"])
            ]
        ),
        .binaryTarget(
            name: "native_xcframework",
            url: "https://github.com/ADAMMA-CDHI-ETH-Zurich/CLAID/releases/download/v0.6.5-pre/claid_native_xcframework.xcframework.zip",
            checksum: "478661cb6557ec5bb5a55f16ad340c4c3dd474175c5505d3e1fe21b1186a55a8"
        ),
        .testTarget(
            name: "CLAIDTests",
            dependencies: ["CLAID"]
        )
    ]
)
