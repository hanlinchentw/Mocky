//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

import XCTest

final class ExampleUITests: UITestCases {
	override func setUp() {
		taEnvironment = .mockLocalData
		super.setUp()
	}

    func testExample() async throws {
//				mockFile("Mock.json", for: "/api/v2/pokemon")
				XCTAssertTrue(app.cells["ExampleCell-bulbasaur"].exists)
    }
}
