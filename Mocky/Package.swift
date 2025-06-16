// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Mocky",
	platforms: [
		.iOS(.v16)
	],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(name: "MockyCore", targets: ["MockyCore"]),
		
		// 2️⃣ Linked into unit/UI-test bundles
		.library(name: "MockyXCTestHelpers",
						 targets: ["MockyXCTestHelpers"]),
	],
	targets: [
		// Core – no XCTest, pure Foundation
		.target(name: "MockyCore"),

		// Test helpers – has `import XCTest` and depends on core
		.target(name: "MockyXCTestHelpers",
						dependencies: ["MockyCore"],
						swiftSettings: [.define("MOCKY_TEST_ONLY")]),
	]
)
