//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

@testable import Example
import XCTest
import Mocky

final class ExampleUITests: UITestCases {
	func testExample() {
		mockFile("Mock.json", for: "/api/v2/pokemon")

		XCTAssertNoThrow(try open(.homeListView))

		// Check if A11Y.tableView exists
		XCTAssertTrue(app.tables[A11Y.tableView].waitForExistence(timeout: 5))

		// Check if A11y.cell exists
		XCTAssertTrue(app.cells[A11Y.cell(for: "Leo")].waitForExistence(timeout: 5))
	}
}
