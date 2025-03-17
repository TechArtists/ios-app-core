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

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let packageName = "TAAppCore"

let package = Package(
    name: packageName,
    products: [
        .library(
            name: packageName,
            targets: [packageName]),
    ],
    dependencies: [
        .package(url: "git@github.com:TechArtists/ios-analytics.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "git@github.com:TechArtists/ios-debug-tools.git", .upToNextMajor(from: "1.4.0")),
        .package(url: "git@github.com:TechArtists/ios-swift-log-os-log-handler.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "git@github.com:TechArtists/ios-swift-log-file-log-handler.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: packageName
        ),
    ]
)
