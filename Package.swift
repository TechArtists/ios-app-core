// swift-tools-version: 5.9
/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import PackageDescription

private let packageName = "TAAppCore"

let package = Package(
    name: packageName,
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: packageName,
            targets: [packageName]),
    ],
    dependencies: [
        .package(url: "git@github.com:TechArtists/ios-analytics.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "git@github.com:TechArtists/ios-debug-tools.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "git@github.com:TechArtists/ios-swift-log-os-log-handler.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "git@github.com:TechArtists/ios-swift-log-file-log-handler.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "git@github.com:firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.0.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.2.0"))
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: [
                .product(name: "TAAnalytics", package: "ios-analytics"),
                .product(name: "TADebugTools", package: "ios-debug-tools"),
                .product(name: "SwiftLogOSLogHandler", package: "ios-swift-log-os-log-handler"),
                .product(name: "SwiftLogFileLogHandler", package: "ios-swift-log-file-log-handler"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
    ]
)
